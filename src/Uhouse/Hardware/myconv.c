#include "myconv.h"

int pack(int res, double tem, double hum)
{
    return (res << 24) | ((((char) tem) << 16) & 16711680) | (((char) hum << 8) & 65280) ;
}

char unpack(int offset, int res)
{
    return (char)(res >> offset);
}

char unpack_sta(int p)
{
    return unpack(24, p);
}

char unpack_tem(int p)
{
    return unpack(16, p);
}

char unpack_hum(int p)
{
    return unpack(8, p);
}