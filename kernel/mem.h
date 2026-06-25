#ifndef MEM_H
#define MEM_H
#include "types.h"

// blocks of memory that all have the same size of objects
struct  slab_block{
    short mem_size; // size of memory object
    long free_list; //  a bit map of each object entry , 0 for free, 1 for used
    long object_count; // amount of objects allocated.
    // long *free_block; //next free address, software will update this to the first free block in the bit map each time one is allocated/freed
}; //properly space out objects to be aligned by 32 bit sections, with no padding.


#endif