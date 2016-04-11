#ifndef __GX_UTILS_H__
#define __GX_UTILS_H__

#include <vector>
#include <string>
#include "platform.h"
#include "data.h"
#include "memory.h"
GX_NS_BEGIN

std::string ltrim(const std::string &str) noexcept;
std::string rtrim(const std::string &str) noexcept;
std::string trim(const std::string &str) noexcept;
std::vector<std::string> split(const std::string &str, int c) noexcept;

#ifdef GX_PLATFORM_WIN32
ptr<Data> char2wchar(const char *str) noexcept;
ptr<Data> wchar2char(const wchar_t *str) noexcept;
#endif

GX_NS_END


#endif

