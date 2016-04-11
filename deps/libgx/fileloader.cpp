#include <cstdio>
#include "fileloader.h"
#include "log.h"
GX_NS_BEGIN

ptr<Data> FileLoader::load(const Path &path) noexcept {
	FILE *file = fopen(path.c_str(), "rb");
    if (!file) {
        return nullptr;
    }

    int size = fseek(file, 0, SEEK_END);
    if (size < 0) {
		fclose(file);
        return nullptr;
    }
    size = ftell(file);
    rewind(file);

    object<Data> data(size);
    if (fread(data->data(), 1, size, file) != (size_t)size) {
		fclose(file);
        return nullptr;
    }
	fclose(file);
    return data;
}

GX_NS_END


