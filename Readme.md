# About axi_to_i2s

This is an opensource AXI I2S controller(play-only, no-record).

AXI based DMA is supported, controlling logic can fetch audio data from memory.

An example C driver is as follow:
```c
struct i2s_ip_ctl
{
    volatile uint32_t version;         // 0x0 - 0x3
    volatile uint32_t conf;            // 0x4 - 0x7
    volatile uint32_t pad0[66];      // 0x8 - 0x10f
    volatile uint32_t mm2s_ctrl;       // 0x110
    volatile uint32_t mm2s_status;     // 0x114
    volatile uint32_t mm2s_multiplier; // 0x118
    volatile uint32_t mm2s_period;     // 0x11c
    volatile uint32_t mm2s_dmaaddr;    // 0x120
    volatile uint32_t mm2s_dmaaddr_msb; // 0x124
    volatile uint32_t mm2s_transfer_count; // 0x128
    volatile uint32_t pad1[6];             // 0x12c - 0x143
    volatile uint32_t mm2s_channel_offset; // 0x144
};
static struct i2s_ip_ctl *i2s_ctl;
static void open_i2s_device(void) {
    i2s_ctl = I2S_BASEADDR;
    i2s_ctl->mm2s_ctrl = BIT(1);
    uint32_t iters=0;
    while(i2s_ctl->mm2s_ctrl & BIT(1)) {
        if((iters++) & 0xffff) {
            printf("Open I2S STUCK %x", i2s_ctl->mm2s_ctrl);
            i2s_ctl->mm2s_ctrl = 0;
        }
    }
    i2s_ctl->mm2s_ctrl = BIT(13) | (0x1 << 16) | (0x2 << 19);
    i2s_ctl->mm2s_multiplier = 512;
}
static void close_i2s_device(void) {
    i2s_ctl->mm2s_ctrl = BIT(1);
    uint32_t iters=0;
    while(i2s_ctl->mm2s_ctrl & BIT(1)){
        if((iters++) & 0xffff) {
            printf("Close I2S STUCK");
            i2s_ctl->mm2s_ctrl = 0;
        }
    }
    i2s_ctl->mm2s_ctrl = 0;
}

static void i2s_play_one_frame(uint32_t abuf_ptr) {
    i2s_ctl->mm2s_dmaaddr = abuf_ptr;
    i2s_ctl->mm2s_dmaaddr_msb = 0;
}
```
