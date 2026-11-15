/* Only the Windows release ABI's time_t is needed to parse winsparkle.h.
 * This header lets FFIgen target Windows even without a Windows SDK. */
typedef __INT64_TYPE__ time_t;
