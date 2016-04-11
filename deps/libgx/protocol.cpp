#include "protocol.h"
#include "log.h"

GX_NS_BEGIN

#pragma pack(push)
#pragma pack(1)
struct PackHead {
    uint32_t size;
    uint32_t servlet;
    uint32_t seq;
};
#pragma pack(pop)

#pragma pack(push)
#pragma pack(1)
struct ClientPackHead {
    uint16_t size;
    uint32_t servlet;
};
#pragma pack(pop)

enum {
    PUS_INIT,
    PUS_HEAD,
    PUS_BODY,
};

Protocol::Protocol() noexcept
: _state(PUS_INIT)
{ }

void Protocol::serial(ProtocolInfo &info, Stream &stream, bool is_response) noexcept {
    size_t size = stream.size();
    ClientPackHead *clientHead = nullptr;
    PackHead *head = nullptr;
    if (info.seq) {
        head = (PackHead*)stream.blank(sizeof(PackHead));
    }
    else {
        clientHead = (ClientPackHead*)stream.blank(sizeof(ClientPackHead));
    }

    if (!is_response) {
        info.message->serial(stream);
    }
    else {
        const IResponse *rsp = static_cast<const IResponse*>(info.message);
        if (rsp->rc) {
            rsp->IResponse::serial(stream);
        }
        else {
            info.message->serial(stream);
        }
    }

    size = stream.size() - size;
    if (info.seq) {
        head->servlet = info.servlet;
        head->seq = info.seq;
        head->size = size;
    }
    else {
        clientHead->servlet = info.servlet;
        clientHead->size = size;
    }
}

int Protocol::unserial(ProtocolInfo &info, Stream &stream, bool is_ap) noexcept {
    while (1) {
        switch (_state) {
        case PUS_INIT: {
            if (is_ap) {
                if (stream.size() < sizeof(ClientPackHead)) {
                    return 0;
                }
            }
            else {
                if (stream.size() < sizeof(PackHead)) {
                    return 0;
                }
            }
            _state++;
        }
        case PUS_HEAD: {
            if (is_ap) {
                ClientPackHead head;
                stream.read(&head, sizeof(head));
                _servlet = head.servlet;
                _seq = 0;
                _size = head.size;
                if (_size < sizeof(ClientPackHead)) {
                    return -1;
                }
                _size -= sizeof(ClientPackHead);
            }
            else {
                PackHead head;
                stream.read(&head, sizeof(head));
                _servlet = head.servlet;
                _seq = head.seq;
                _size = head.size;
                if (_size < sizeof(PackHead)) {
                    return -1;
                }
                _size -= sizeof(PackHead);
            }
            _state++;
        }
        case PUS_BODY: {
            if (stream.size() < _size) {
                return 0;
            }
            info.servlet = _servlet;
            info.seq = _seq;
            info.size = _size;
            _state = PUS_INIT;
            return 1;
        }
        default:
            return -1;
        }
    }
}

#ifndef __GX_SERVER_H__
ptr<ProtoBase> ProtoMgr::protocol(unsigned id) {
    auto it = _map.find(id);
    if (it == _map.end()) {
        return nullptr;
    }
    return it->second;
}

void ProtoMgr::registerProto(ptr<ProtoBase> proto) {
    _map.emplace(proto->id(), proto);
}

#endif
GX_NS_END
