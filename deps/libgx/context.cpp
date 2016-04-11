#include "context.h"
#include "peer.h"
#include "coroutine.h"
#include "log.h"
#include "application.h"

GX_NS_BEGIN

bool ContextBase::running() const noexcept {
    return _co->running();
}

std::function<ptr<Context>()> Context::factory = []() {
    return object<Context>();
};

Context::Context() noexcept 
: _network(),
  _servlet(),
  _seq(),
  _size(),
  _call_result()
{ }

Context::~Context() noexcept {
    finish();
}

bool Context::begin(Network *network, Peer *peer) noexcept {
    assert(network);
    _network = network;
    _peer = peer;
    return true;
}

bool Context::commit() noexcept {
    clear();
    return true;
}

void Context::rollback(bool fail) noexcept {
    clear();
}

void Context::clear() noexcept {
    if (_timer) {
        _timer->close();
        _timer = nullptr;
    }
}

void Context::finish() noexcept {
    _network = nullptr;
    _peer = nullptr;
    _servlet = nullptr;
    _seq = 0;
    _size = 0;
    _pool = nullptr;
}

void Context::call_ok() noexcept {
    _call_result = GX_CALL_OK;
    co()->resume();
}

void Context::call_cancel() noexcept {
    _call_result = GX_CALL_CANCEL;
    co()->resume();
}

void Context::call_timedout() noexcept {
    _call_result = GX_CALL_TIMEDOUT;
    co()->resume();
}

void Context::call_yield() noexcept {
    assert(co() == Coroutine::self());
    _call_result = GX_CALL_OK;
    if (!Coroutine::yield()) {
        throw CallCancelException();
    }
    switch (_call_result) {
    case GX_CALL_TIMEDOUT:
        throw ServletException(GX_ETIMEOUT);
    case GX_CALL_CANCEL:
        throw CallCancelException();
    default:
        assert(0);
        return;
    }
}

void Context::sleep(timeval_t time) noexcept {
    assert(co() == Coroutine::self());
    if (!time) {
        return;
    }
    the_app->timer_manager()->schedule(time, [this](Timer&, timeval_t){
        co()->resume();
        return 0;
    });
    Coroutine::yield();
}

Context *the_context() noexcept {
    return Coroutine::self()->context();
}


GX_NS_END

