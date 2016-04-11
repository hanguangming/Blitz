#ifndef __GX_FILELOADER_H__
#define __GX_FILELOADER_H__

#include "memory.h"
#include "data.h"
#include "path.h"

GX_NS_BEGIN

struct FileLoader {
	static ptr<Data> load(const Path &path) noexcept;
	static ptr<Data> load(const char *path) noexcept {
		return load(Path(path));
	}
};

GX_NS_END

#endif

