#ifdef __GX_SERVER__
#include "servlet.h"
#include "log.h"
#include "coroutine.h"
#include "rc.h"

GX_NS_BEGIN

#define GX_KEEPALIVE_SERVLET 0x40000001

bool the_dump_message = true;

/* ServletManager */
void ServletManager::registerServlet(ptr<ServletBase> servlet, bool use_coroutine, const char *file, size_t line) {
    if (!_map.emplace(servlet->id(), servlet).second) {
        log_die("repeatly register servlet '%s(%x)'.", servlet->name(), servlet->id());
    }
    servlet->_use_coroutine = use_coroutine;
}

inline void ServletManager::execute(Context *ctx) {
    int rc = 0;

    if (!ctx->peer()) {
        return;
    }

    ServletBase *servlet = ctx->_servlet;
    ISerial *req = servlet->create_request(ctx->peer()->input(), ctx->_size, ctx->pool());
    if (!req) {
        ctx->rollback(false);
        log_debug("unserial protocol '%x' failed.", servlet->id());
        ctx->peer()->close();
        return;
    }

    IResponse *rsp = servlet->create_response(ctx->pool());

    if (servlet->dump_msg()) {
        req->dump(nullptr, 0, ctx->pool());
        ctx->pool()->grow1('\0');
        log_debug("\n%s", (char*)ctx->pool()->finish());
    }

    try {
        if ((rc = servlet->execute(req, rsp)) < 0) {
            ctx->rollback(false);
            if (ctx->peer()) {
                ctx->peer()->close();
            }
        }
        else {
            if (rc) {
                ctx->rollback(false);
            }
            else {
                ctx->commit();
            }

            if (ctx->peer()) {
                if (rsp) {
                    if (ctx->_servlet->dump_msg()) {
                        rsp->dump(nullptr, 0, ctx->pool());
                        ctx->pool()->grow1('\0');
                        log_debug("\n%s", (char*)ctx->pool()->finish());
                    }
                    ctx->peer()->send(ctx->_servlet->id(), ctx->_seq, rsp);
                }
            }
        }
    } catch (ServletException &e) {
        if (ctx->peer() && rsp) {
            rsp->rc = e.rc;
            if (ctx->_servlet->dump_msg()) {
                rsp->dump(nullptr, 0, ctx->pool());
                ctx->pool()->grow1('\0');
                log_debug("\n%s", (char*)ctx->pool()->finish());
            }
            ctx->peer()->send(ctx->_servlet->id(), ctx->_seq, rsp);
        }
        ctx->rollback(true);
    } catch (CallCancelException &e) {
        ctx->rollback(false);
    }

    if (servlet->_short_link && ctx->peer()) {
        ctx->peer()->close(servlet->_linger);
    }
}

void ServletManager::routine(void *param) noexcept {
    timeval_t t1 = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()
    ).count();

    Peer *peer = static_cast<Peer*>(param);
    Context *ctx = Coroutine::self()->context();
    if (ctx->begin(peer->network(), peer)) {
        static_cast<ServletManager*>(param)->execute(ctx);
    }
    ctx->finish();

    timeval_t t2 = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()
    ).count();
    log_debug("servlet running time %lu.", t2 - t1);
}


void ServletManager::execute(unsigned servlet_id, unsigned seq, unsigned size, Peer *peer) noexcept {
    if (servlet_id == GX_KEEPALIVE_SERVLET) {
        if (seq || size) {
            peer->close();
            return;
        }
        return;
    }

    auto it = _map.find(servlet_id);
    if (it == _map.end()) {
        log_debug("servlet 0x%x not registered.", servlet_id);
        peer->close();
        return;
    }

    ServletBase *servlet = it->second;

    Coroutine *co;
    bool use_co = servlet->use_coroutine();
    if (use_co) {
        co = Coroutine::spawn(routine, peer);
    }
    else {
        co = Coroutine::self();
    }

    if (!co) {
        log_debug("no coroutine available.");
        peer->input().read(nullptr, size);
        return;
    }

    co->context()->_servlet = servlet;
    co->context()->_seq = seq;
    co->context()->_size = size;

    if (use_co) {
        co->resume();
    }
    else {
        routine(peer);
    }
}

void ServletManager::execute(unsigned servlet_id, ISerial *req, IResponse *rsp) noexcept {
    auto it = _map.find(servlet_id);
    if (it == _map.end()) {
        log_debug("servlet 0x%x not registered.", servlet_id);
        return;
    }
    ServletBase *servlet = it->second;
    servlet->execute(req, rsp);
}

GX_NS_END
#endif

