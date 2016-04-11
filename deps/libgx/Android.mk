LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := libgx_static

LOCAL_MODULE_FILENAME := libgx_static

FILE_LIST  = $(wildcard $(LOCAL_PATH)/*.cpp)
LOCAL_SRC_FILES := $(FILE_LIST:$(LOCAL_PATH)/%=%)

LOCAL_C_INCLUDES := 					\
	$(LOCAL_PATH)/../../include/libgx	\
	$(LOCAL_PATH)/../../include/lua		\
	$(LOCAL_PATH)/../../include         \
	$(LOCAL_PATH)/../libiconv/include

LOCAL_STATIC_LIBRARIES += lua_static

include $(BUILD_STATIC_LIBRARY)


