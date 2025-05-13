/* SPDX-License-Identifier: MIT */
/*
 * Authors: Fabrice Buoro <fabrice@tarides.com>
 *          Samuel Hym <samuel@tarides.com>
 *
 * Copyright (c) 2024-2025, Tarides.
 *               All rights reserved.
*/

#ifndef YIELD_H
#define YIELD_H

#include <stdint.h>

#define MAX_NET_DEVICES   16
#define MAX_BLK_DEVICES   16
#define MAX_BLK_TOKENS    62

typedef unsigned int net_id_t;

typedef unsigned int block_id_t;
typedef unsigned int token_id_t;

void signal_netdev_queue_ready(net_id_t id);
void set_netdev_queue_empty(net_id_t id);

void signal_block_request_ready(block_id_t devid, token_id_t tokenid);
void set_block_request_completed(block_id_t devid, token_id_t tokenid);

#endif /* !YIELD_H */
