#include "cron.h"

GX_NS_BEGIN

#define MAX_TEMPSTR 256

static const char *__get_number(const char *str, int *numptr, const char *terms) {
	char temp[MAX_TEMPSTR], *pc;
	int len;

	pc = temp;
	len = 0;

	while (isdigit((unsigned char)*str)) {
		if (++len >= MAX_TEMPSTR) {
            return nullptr;
        }
		*pc++ = *str++;
	}
	*pc = '\0';
    if (!len) {
        return nullptr;
    }
    if (*str && !strchr(terms, *str)) {
        return nullptr;
    }
    *numptr = atoi(temp);
    return str;
}

static bool __set_element(char *bits, int low, int high, int number) {
    if (number < low || number > high) {
        return false;
    }

	bitstr_base::set(bits, number - low);
	return true;
}

static const char *__get_range(const char *str, char *bits, unsigned low, unsigned high) noexcept {
    int i, num1, num2, num3;
    if (*str == '*') {
        num1 = low;
        num2 = high;
        ++str;
        if (*str && *str != ',' && *str != '/') {
            return nullptr;
        }
    }
    else {
        if (!(str = __get_number(str, &num1, ",- \t\n"))) {
            return nullptr;
        }

        if (*str != '-') {
            if (!__set_element(bits, low, high, num1)) {
                return nullptr;
            }
            return str;
        }
        else {
            ++str;
            if (!*str) {
                return nullptr;
            }
            if (!(str = __get_number(str, &num2, "/, \t\n"))) {
                return nullptr;
            }
            if (num1 > num2) {
                return nullptr;
            }
        }
    }

    if (*str == '/') {
        ++str;
        if (!*str) {
            return nullptr;
        }
        if (!(str = __get_number(str, &num3, ", \t\n"))) {
            return nullptr;
        }
        if (num3 == 0) {
            return nullptr;
        }
    }
    else {
        num3 = 1;
    }

    for (i = num1; i <= num2; i += num3) {
        if (!__set_element(bits, low, high, i)) {
            return nullptr;
        }
    }
    return str;
}

static bool __get_list(const char *str, char *bits, unsigned low, unsigned high) noexcept {
    bitstr_base::clear(bits, 0, (high - low));
    while (*str) {
        if (!(str = __get_range(str, bits, low, high))) {
            return false;
        }
        switch (*str) {
        case '\0':
            break;
        case ',':
            ++str;
            break;
        default:
            return false;
        }
    }
    return true;
}

bool Cron::add_job(
    const char *month, 
    const char *day, 
    const char *week, 
    const char *hour, 
    const char *minute, 
    const std::function<job_handler_t> &handler) noexcept 
{
    do {
        if (!minute) {
            minute = "*";
        }
        if (!__get_list(minute, _minute.data(), FIRST_MINUTE, LAST_MINUTE)) {
            break;
        }
        if (!hour) {
            hour = "*";
        }
        if (!__get_list(hour, _hour.data(), FIRST_HOUR, LAST_HOUR)) {
            break;
        }
        if (!week) {
            week = "*";
        }
        if (!__get_list(week, _week.data(), FIRST_DOW, LAST_DOW)) {
            break;
        }
        if (!day) {
            day = "*";
        }
        if (!__get_list(day, _day.data(), FIRST_DOM, LAST_DOM)) {
            break;
        }
        if (!month) {
            month = "*";
        }
        if (!__get_list(month, _month.data(), FIRST_MONTH, LAST_MONTH)) {
            break;
        }
        if (_week.test(0) || _week.test(7)) {
            _week.set(0);
            _week.set(7);
        }
        return true;
    } while (0);
    return false;
}

GX_NS_END

