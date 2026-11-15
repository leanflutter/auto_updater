#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "include/Sparkle/Sparkle.h"

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

typedef struct {
  int64_t version;
  void* (*newWaiter)(void);
  void (*awaitWaiter)(void*);
  void* (*currentIsolate)(void);
  void (*enterIsolate)(void*);
  void (*exitIsolate)(void);
  int64_t (*getMainPortId)(void);
  bool (*getCurrentThreadOwnsIsolate)(int64_t);
  void (*invokeListenerPortBlock)(int64_t port, void*);
  void (*invokeBlockingPortBlock)(int64_t port, void*, void*);
} DOBJC_Context;

id objc_retainBlock(id);

#define BLOCKING_BLOCK_IMPL(ctx, TYPE, SIG, INVOKE_DIRECT, INVOKE_LISTENER)    \
  assert(ctx->version >= 1);                                                   \
  void* targetIsolate = ctx->currentIsolate();                                 \
  int64_t targetPort = ctx->getMainPortId == NULL ? 0 : ctx->getMainPortId();  \
  __block __weak TYPE weakSelfBlock = nil;                                     \
  TYPE strongSelfBlock = [SIG {                                                \
    void* currentIsolate = ctx->currentIsolate();                              \
    bool mayEnterIsolate =                                                     \
        currentIsolate == NULL &&                                              \
        ctx->getCurrentThreadOwnsIsolate != NULL &&                            \
        ctx->getCurrentThreadOwnsIsolate(targetPort);                          \
    if (currentIsolate == targetIsolate || mayEnterIsolate) {                  \
      if (mayEnterIsolate) {                                                   \
        ctx->enterIsolate(targetIsolate);                                      \
      }                                                                        \
      INVOKE_DIRECT;                                                           \
      if (mayEnterIsolate) {                                                   \
        ctx->exitIsolate();                                                    \
      }                                                                        \
    } else {                                                                   \
      void* waiter = ctx->newWaiter();                                         \
      TYPE selfRetain = [weakSelfBlock copy];                                  \
      INVOKE_LISTENER;                                                         \
      ctx->awaitWaiter(waiter);                                                \
      (void)selfRetain;                                                        \
    }                                                                          \
  } copy];                                                                     \
  weakSelfBlock = strongSelfBlock;                                             \
  return strongSelfBlock;


typedef id  (^_ProtocolTrampoline)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx7e8d_protocolTrampoline_xr62hr(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_1)(void * sel, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx7e8d_protocolTrampoline_1u4xn97(id target, void * sel, id arg1, BOOL arg2) {
  return ((_ProtocolTrampoline_1)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_2)(void * sel, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx7e8d_protocolTrampoline_qfyidt(id target, void * sel, id arg1, id arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_2)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef NSComparisonResult  (^_ProtocolTrampoline_3)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
NSComparisonResult  _1wx7e8d_protocolTrampoline_1dp38tu(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_3)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_4)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx7e8d_protocolTrampoline_1yw2rcr(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_5)(void * sel, id arg1, id * arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx7e8d_protocolTrampoline_g9sof0(id target, void * sel, id arg1, id * arg2, id arg3) {
  return ((_ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_6)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx7e8d_protocolTrampoline_zi5eed(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_6)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_7)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx7e8d_protocolTrampoline_e3qsqz(id target, void * sel) {
  return ((_ProtocolTrampoline_7)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^_ProtocolTrampoline_8)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx7e8d_protocolTrampoline_3su7tt(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_8)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^_ProtocolTrampoline_9)(void * sel, id arg1, SPUUpdateCheck arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx7e8d_protocolTrampoline_1xqiul7(id target, void * sel, id arg1, SPUUpdateCheck arg2, id * arg3) {
  return ((_ProtocolTrampoline_9)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_10)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx7e8d_protocolTrampoline_2n06mv(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_11)(void * sel, id arg1, id arg2, SPUUpdateCheck arg3, id * arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx7e8d_protocolTrampoline_6bbv1(id target, void * sel, id arg1, id arg2, SPUUpdateCheck arg3, id * arg4) {
  return ((_ProtocolTrampoline_11)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_12)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx7e8d_protocolTrampoline_rptcvw(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_12)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_13)(void * sel, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _1wx7e8d_protocolTrampoline_9k4e9l(id target, void * sel, id arg1, BOOL arg2) {
  return ((_ProtocolTrampoline_13)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_1pl9qdv : NSObject
@property (copy) id block;

@end
@implementation _1wx7e8d_BlockArgs_1pl9qdv
@end

typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1wx7e8d_wrapListenerBlock_1pl9qdv(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline weakSelfBlock = nil;
  _ListenerTrampoline strongSelfBlock = [^void() {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1pl9qdv* args = [[_1wx7e8d_BlockArgs_1pl9qdv alloc] init];
      args.block = weakSelfBlock;
      
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _1wx7e8d_wrapBlockingBlock_1pl9qdv(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline, ^void(), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1pl9qdv* args = [[_1wx7e8d_BlockArgs_1pl9qdv alloc] init];
      args.block = weakSelfBlock;
      
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1pl9qdv* args = [[_1wx7e8d_BlockArgs_1pl9qdv alloc] init];
      args.block = weakSelfBlock;
      
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_1mooj9m : NSObject
@property (copy) id block;
@property SPUUserUpdateChoice arg0;
@end
@implementation _1wx7e8d_BlockArgs_1mooj9m
@end

typedef void  (^_ListenerTrampoline_1)(SPUUserUpdateChoice arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1wx7e8d_wrapListenerBlock_1mooj9m(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_1 weakSelfBlock = nil;
  _ListenerTrampoline_1 strongSelfBlock = [^void(SPUUserUpdateChoice arg0) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1mooj9m* args = [[_1wx7e8d_BlockArgs_1mooj9m alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, SPUUserUpdateChoice arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _1wx7e8d_wrapBlockingBlock_1mooj9m(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_1, ^void(SPUUserUpdateChoice arg0), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1mooj9m* args = [[_1wx7e8d_BlockArgs_1mooj9m alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1mooj9m* args = [[_1wx7e8d_BlockArgs_1mooj9m alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_xtuoz7 : NSObject
@property (copy) id block;
@property (strong) id arg0;
@end
@implementation _1wx7e8d_BlockArgs_xtuoz7
@end

typedef void  (^_ListenerTrampoline_2)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1wx7e8d_wrapListenerBlock_xtuoz7(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_2 weakSelfBlock = nil;
  _ListenerTrampoline_2 strongSelfBlock = [^void(id arg0) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_xtuoz7* args = [[_1wx7e8d_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _1wx7e8d_wrapBlockingBlock_xtuoz7(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_2, ^void(id arg0), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_xtuoz7* args = [[_1wx7e8d_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_xtuoz7* args = [[_1wx7e8d_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_ovsamd : NSObject
@property (copy) id block;
@property void * arg0;
@end
@implementation _1wx7e8d_BlockArgs_ovsamd
@end

typedef void  (^_ListenerTrampoline_3)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1wx7e8d_wrapListenerBlock_ovsamd(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_3 weakSelfBlock = nil;
  _ListenerTrampoline_3 strongSelfBlock = [^void(void * arg0) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_ovsamd* args = [[_1wx7e8d_BlockArgs_ovsamd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _1wx7e8d_wrapBlockingBlock_ovsamd(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_3, ^void(void * arg0), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_ovsamd* args = [[_1wx7e8d_BlockArgs_ovsamd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_ovsamd* args = [[_1wx7e8d_BlockArgs_ovsamd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_14)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_ovsamd(id target, void * sel) {
  return ((_ProtocolTrampoline_14)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_18v1jvf : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@end
@implementation _1wx7e8d_BlockArgs_18v1jvf
@end

typedef void  (^_ListenerTrampoline_4)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1wx7e8d_wrapListenerBlock_18v1jvf(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_4 weakSelfBlock = nil;
  _ListenerTrampoline_4 strongSelfBlock = [^void(void * arg0, id arg1) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_18v1jvf* args = [[_1wx7e8d_BlockArgs_18v1jvf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _1wx7e8d_wrapBlockingBlock_18v1jvf(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_4, ^void(void * arg0, id arg1), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_18v1jvf* args = [[_1wx7e8d_BlockArgs_18v1jvf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_18v1jvf* args = [[_1wx7e8d_BlockArgs_18v1jvf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_15)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_15)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_jk1ljc : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (copy) id arg2;
@end
@implementation _1wx7e8d_BlockArgs_jk1ljc
@end

typedef void  (^_ListenerTrampoline_5)(void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1wx7e8d_wrapListenerBlock_jk1ljc(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_5 weakSelfBlock = nil;
  _ListenerTrampoline_5 strongSelfBlock = [^void(void * arg0, id arg1, id arg2) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_jk1ljc* args = [[_1wx7e8d_BlockArgs_jk1ljc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _1wx7e8d_wrapBlockingBlock_jk1ljc(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_5, ^void(void * arg0, id arg1, id arg2), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_jk1ljc* args = [[_1wx7e8d_BlockArgs_jk1ljc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_jk1ljc* args = [[_1wx7e8d_BlockArgs_jk1ljc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_16)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_jk1ljc(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_16)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_fjrv01 : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@end
@implementation _1wx7e8d_BlockArgs_fjrv01
@end

typedef void  (^_ListenerTrampoline_6)(void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1wx7e8d_wrapListenerBlock_fjrv01(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_6 weakSelfBlock = nil;
  _ListenerTrampoline_6 strongSelfBlock = [^void(void * arg0, id arg1, id arg2) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_fjrv01* args = [[_1wx7e8d_BlockArgs_fjrv01 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _1wx7e8d_wrapBlockingBlock_fjrv01(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_6, ^void(void * arg0, id arg1, id arg2), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_fjrv01* args = [[_1wx7e8d_BlockArgs_fjrv01 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_fjrv01* args = [[_1wx7e8d_BlockArgs_fjrv01 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_17)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_fjrv01(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_17)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_ve6f9k : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property double arg2;
@end
@implementation _1wx7e8d_BlockArgs_ve6f9k
@end

typedef void  (^_ListenerTrampoline_7)(void * arg0, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1wx7e8d_wrapListenerBlock_ve6f9k(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_7 weakSelfBlock = nil;
  _ListenerTrampoline_7 strongSelfBlock = [^void(void * arg0, id arg1, double arg2) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_ve6f9k* args = [[_1wx7e8d_BlockArgs_ve6f9k alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, void * arg0, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _1wx7e8d_wrapBlockingBlock_ve6f9k(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_7, ^void(void * arg0, id arg1, double arg2), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_ve6f9k* args = [[_1wx7e8d_BlockArgs_ve6f9k alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_ve6f9k* args = [[_1wx7e8d_BlockArgs_ve6f9k alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_18)(void * sel, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_ve6f9k(id target, void * sel, id arg1, double arg2) {
  return ((_ProtocolTrampoline_18)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_s38yja : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property SPUUpdateCheck arg2;
@property (strong) id arg3;
@end
@implementation _1wx7e8d_BlockArgs_s38yja
@end

typedef void  (^_ListenerTrampoline_8)(void * arg0, id arg1, SPUUpdateCheck arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1wx7e8d_wrapListenerBlock_s38yja(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_8 weakSelfBlock = nil;
  _ListenerTrampoline_8 strongSelfBlock = [^void(void * arg0, id arg1, SPUUpdateCheck arg2, id arg3) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_s38yja* args = [[_1wx7e8d_BlockArgs_s38yja alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_8)(void * waiter, void * arg0, id arg1, SPUUpdateCheck arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _1wx7e8d_wrapBlockingBlock_s38yja(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_8, ^void(void * arg0, id arg1, SPUUpdateCheck arg2, id arg3), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_s38yja* args = [[_1wx7e8d_BlockArgs_s38yja alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_s38yja* args = [[_1wx7e8d_BlockArgs_s38yja alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_19)(void * sel, id arg1, SPUUpdateCheck arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_s38yja(id target, void * sel, id arg1, SPUUpdateCheck arg2, id arg3) {
  return ((_ProtocolTrampoline_19)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_wmfsmg : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property SPUUserUpdateChoice arg2;
@property (strong) id arg3;
@property (strong) id arg4;
@end
@implementation _1wx7e8d_BlockArgs_wmfsmg
@end

typedef void  (^_ListenerTrampoline_9)(void * arg0, id arg1, SPUUserUpdateChoice arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1wx7e8d_wrapListenerBlock_wmfsmg(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_9 weakSelfBlock = nil;
  _ListenerTrampoline_9 strongSelfBlock = [^void(void * arg0, id arg1, SPUUserUpdateChoice arg2, id arg3, id arg4) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_wmfsmg* args = [[_1wx7e8d_BlockArgs_wmfsmg alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_9)(void * waiter, void * arg0, id arg1, SPUUserUpdateChoice arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _1wx7e8d_wrapBlockingBlock_wmfsmg(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_9, ^void(void * arg0, id arg1, SPUUserUpdateChoice arg2, id arg3, id arg4), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_wmfsmg* args = [[_1wx7e8d_BlockArgs_wmfsmg alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_wmfsmg* args = [[_1wx7e8d_BlockArgs_wmfsmg alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      args.arg4 = arg4;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_20)(void * sel, id arg1, SPUUserUpdateChoice arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_wmfsmg(id target, void * sel, id arg1, SPUUserUpdateChoice arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_20)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_1tz5yf : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property (strong) id arg3;
@end
@implementation _1wx7e8d_BlockArgs_1tz5yf
@end

typedef void  (^_ListenerTrampoline_10)(void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1wx7e8d_wrapListenerBlock_1tz5yf(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_10 weakSelfBlock = nil;
  _ListenerTrampoline_10 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, id arg3) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1tz5yf* args = [[_1wx7e8d_BlockArgs_1tz5yf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_10)(void * waiter, void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _1wx7e8d_wrapBlockingBlock_1tz5yf(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_10, ^void(void * arg0, id arg1, id arg2, id arg3), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1tz5yf* args = [[_1wx7e8d_BlockArgs_1tz5yf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1tz5yf* args = [[_1wx7e8d_BlockArgs_1tz5yf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_21)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_1tz5yf(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_21)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_bklti2 : NSObject
@property (copy) id block;
@property void * arg0;
@property (strong) id arg1;
@property (strong) id arg2;
@property (copy) id arg3;
@end
@implementation _1wx7e8d_BlockArgs_bklti2
@end

typedef void  (^_ListenerTrampoline_11)(void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1wx7e8d_wrapListenerBlock_bklti2(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_11 weakSelfBlock = nil;
  _ListenerTrampoline_11 strongSelfBlock = [^void(void * arg0, id arg1, id arg2, id arg3) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_bklti2* args = [[_1wx7e8d_BlockArgs_bklti2 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_11)(void * waiter, void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _1wx7e8d_wrapBlockingBlock_bklti2(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_11, ^void(void * arg0, id arg1, id arg2, id arg3), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_bklti2* args = [[_1wx7e8d_BlockArgs_bklti2 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_bklti2* args = [[_1wx7e8d_BlockArgs_bklti2 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_22)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_bklti2(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_22)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_1d4g4wu : NSObject
@property (copy) id block;
@property void * arg0;
@property uint64_t arg1;
@end
@implementation _1wx7e8d_BlockArgs_1d4g4wu
@end

typedef void  (^_ListenerTrampoline_12)(void * arg0, uint64_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1wx7e8d_wrapListenerBlock_1d4g4wu(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_12 weakSelfBlock = nil;
  _ListenerTrampoline_12 strongSelfBlock = [^void(void * arg0, uint64_t arg1) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1d4g4wu* args = [[_1wx7e8d_BlockArgs_1d4g4wu alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_12)(void * waiter, void * arg0, uint64_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _1wx7e8d_wrapBlockingBlock_1d4g4wu(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_12, ^void(void * arg0, uint64_t arg1), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1d4g4wu* args = [[_1wx7e8d_BlockArgs_1d4g4wu alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1d4g4wu* args = [[_1wx7e8d_BlockArgs_1d4g4wu alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_23)(void * sel, uint64_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_1d4g4wu(id target, void * sel, uint64_t arg1) {
  return ((_ProtocolTrampoline_23)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_10lndml : NSObject
@property (copy) id block;
@property void * arg0;
@property BOOL arg1;
@end
@implementation _1wx7e8d_BlockArgs_10lndml
@end

typedef void  (^_ListenerTrampoline_13)(void * arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1wx7e8d_wrapListenerBlock_10lndml(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_13 weakSelfBlock = nil;
  _ListenerTrampoline_13 strongSelfBlock = [^void(void * arg0, BOOL arg1) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_10lndml* args = [[_1wx7e8d_BlockArgs_10lndml alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_13)(void * waiter, void * arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _1wx7e8d_wrapBlockingBlock_10lndml(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_13, ^void(void * arg0, BOOL arg1), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_10lndml* args = [[_1wx7e8d_BlockArgs_10lndml alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_10lndml* args = [[_1wx7e8d_BlockArgs_10lndml alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_24)(void * sel, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_10lndml(id target, void * sel, BOOL arg1) {
  return ((_ProtocolTrampoline_24)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_1mdlppl : NSObject
@property (copy) id block;
@property void * arg0;
@property BOOL arg1;
@property (strong) id arg2;
@property (strong) id arg3;
@end
@implementation _1wx7e8d_BlockArgs_1mdlppl
@end

typedef void  (^_ListenerTrampoline_14)(void * arg0, BOOL arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1wx7e8d_wrapListenerBlock_1mdlppl(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_14 weakSelfBlock = nil;
  _ListenerTrampoline_14 strongSelfBlock = [^void(void * arg0, BOOL arg1, id arg2, id arg3) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1mdlppl* args = [[_1wx7e8d_BlockArgs_1mdlppl alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_14)(void * waiter, void * arg0, BOOL arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _1wx7e8d_wrapBlockingBlock_1mdlppl(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_14, ^void(void * arg0, BOOL arg1, id arg2, id arg3), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1mdlppl* args = [[_1wx7e8d_BlockArgs_1mdlppl alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1mdlppl* args = [[_1wx7e8d_BlockArgs_1mdlppl alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      args.arg3 = arg3;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_25)(void * sel, BOOL arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_1mdlppl(id target, void * sel, BOOL arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_25)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_ftecxq : NSObject
@property (copy) id block;
@property void * arg0;
@property BOOL arg1;
@property (copy) id arg2;
@end
@implementation _1wx7e8d_BlockArgs_ftecxq
@end

typedef void  (^_ListenerTrampoline_15)(void * arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1wx7e8d_wrapListenerBlock_ftecxq(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_15 weakSelfBlock = nil;
  _ListenerTrampoline_15 strongSelfBlock = [^void(void * arg0, BOOL arg1, id arg2) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_ftecxq* args = [[_1wx7e8d_BlockArgs_ftecxq alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_15)(void * waiter, void * arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _1wx7e8d_wrapBlockingBlock_ftecxq(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_15, ^void(void * arg0, BOOL arg1, id arg2), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_ftecxq* args = [[_1wx7e8d_BlockArgs_ftecxq alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_ftecxq* args = [[_1wx7e8d_BlockArgs_ftecxq alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_26)(void * sel, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_ftecxq(id target, void * sel, BOOL arg1, id arg2) {
  return ((_ProtocolTrampoline_26)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_18sfmo2 : NSObject
@property (copy) id block;
@property void * arg0;
@property double arg1;
@end
@implementation _1wx7e8d_BlockArgs_18sfmo2
@end

typedef void  (^_ListenerTrampoline_16)(void * arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1wx7e8d_wrapListenerBlock_18sfmo2(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_16 weakSelfBlock = nil;
  _ListenerTrampoline_16 strongSelfBlock = [^void(void * arg0, double arg1) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_18sfmo2* args = [[_1wx7e8d_BlockArgs_18sfmo2 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_16)(void * waiter, void * arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _1wx7e8d_wrapBlockingBlock_18sfmo2(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_16, ^void(void * arg0, double arg1), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_18sfmo2* args = [[_1wx7e8d_BlockArgs_18sfmo2 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_18sfmo2* args = [[_1wx7e8d_BlockArgs_18sfmo2 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_27)(void * sel, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_18sfmo2(id target, void * sel, double arg1) {
  return ((_ProtocolTrampoline_27)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _1wx7e8d_BlockArgs_1l4hxwm : NSObject
@property (copy) id block;
@property void * arg0;
@property (copy) id arg1;
@end
@implementation _1wx7e8d_BlockArgs_1l4hxwm
@end

typedef void  (^_ListenerTrampoline_17)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1wx7e8d_wrapListenerBlock_1l4hxwm(
    int64_t port, DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_17 weakSelfBlock = nil;
  _ListenerTrampoline_17 strongSelfBlock = [^void(void * arg0, id arg1) {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1l4hxwm* args = [[_1wx7e8d_BlockArgs_1l4hxwm alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void*)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void  (^_BlockingTrampoline_17)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _1wx7e8d_wrapBlockingBlock_1l4hxwm(int64_t port, DOBJC_Context* ctx,
    void (*directInvoke)(void*)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, _ListenerTrampoline_17, ^void(void * arg0, id arg1), {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1l4hxwm* args = [[_1wx7e8d_BlockArgs_1l4hxwm alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      directInvoke((__bridge_retained void*)args);
    }
  }, {
    @autoreleasepool {
      _1wx7e8d_BlockArgs_1l4hxwm* args = [[_1wx7e8d_BlockArgs_1l4hxwm alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeBlockingPortBlock(port, (__bridge_retained void*)args, waiter);
    }
  });
}

typedef void  (^_ProtocolTrampoline_28)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _1wx7e8d_protocolTrampoline_1l4hxwm(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_28)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_29)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _1wx7e8d_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((_ProtocolTrampoline_29)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx7e8d_SPUStandardUserDriverDelegate(void) { return @protocol(SPUStandardUserDriverDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx7e8d_SPUUpdaterDelegate(void) { return @protocol(SPUUpdaterDelegate); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx7e8d_SPUUserDriver(void) { return @protocol(SPUUserDriver); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx7e8d_SUVersionComparison(void) { return @protocol(SUVersionComparison); }

__attribute__((visibility("default"))) __attribute__((used))
Protocol* _1wx7e8d_SUVersionDisplay(void) { return @protocol(SUVersionDisplay); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
