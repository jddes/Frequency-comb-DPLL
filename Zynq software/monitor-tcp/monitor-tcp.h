#ifndef MONITOR_TCP_H
#define MONITOR_TCP_H

// Base Oscilloscope address
static const int OSC_BASE_ADDR = 0x00100000;	// this is relative to the start of the fpga address at 0x4000_0000
static const int OSC_BASE_SIZE = 0x30000;

// Oscilloscope Channel A input signal buffer offset
#define OSC_CHA_OFFSET 0x10000

// Oscilloscope Channel B input signal buffer offset
#define OSC_CHB_OFFSET 0x20000
// Oscilloscope structure declaration
typedef struct osc_control_s {

    /** @brief Offset 0x00 - configuration register
     *
     * Configuration register (offset 0x00):
     * bit [0] - arm_trigger
     * bit [1] - rst_wr_state_machine
     * bit [2] - trigger_status
     * bit [3] - arm_keep
     * bits [31:4] - reserved
     */
    uint32_t conf;

    /** @brief Offset 0x04 - trigger source register
     *
     * Trigger source register (offset 0x04):
     * bits [ 2 : 0] - trigger source:
     * 1 - trig immediately
     * 2 - ChA positive edge
     * 3 - ChA negative edge
     * 4 - ChB positive edge
     * 5 - ChB negative edge
     * 6 - External trigger 0
     * 7 - External trigger 1
     * bits [31 : 3] -reserved
     */
    uint32_t trig_source;

    /** @brief Offset 0x08 - Channel A threshold register
     *
     * Channel A threshold register (offset 0x08):
     * bits [13: 0] - ChA threshold
     * bits [31:14] - reserved
     */
    uint32_t cha_thr;

    /** @brief Offset 0x0C - Channel B threshold register
     *
     * Channel B threshold register (offset 0x0C):
     * bits [13: 0] - ChB threshold
     * bits [31:14] - reserved
     */
    uint32_t chb_thr;

    /** @brief Offset 0x10 - After trigger delay register
     *
     * After trigger delay register (offset 0x10)
     * bits [31: 0] - trigger delay
     * 32 bit number - how many decimated samples should be stored into a buffer.
     * (max 16k samples)
     */
    uint32_t trigger_delay;

    /** @brief Offset 0x14 - Data decimation register
     *
     * Data decimation register (offset 0x14):
     * bits [16: 0] - decimation factor, legal values:
     * 1, 8, 64, 1024, 8192 65536
     * If other values are written data is undefined
     * bits [31:17] - reserved
     */
    uint32_t data_dec;

    /** @brief Offset 0x18 - Current write pointer register
     *
     * Current write pointer register (offset 0x18), read only:
     * bits [13: 0] - current write pointer
     * bits [31:14] - reserved
     */
    uint32_t wr_ptr_cur;

    /** @brief Offset 0x1C - Trigger write pointer register
     *
     * Trigger write pointer register (offset 0x1C), read only:
     * bits [13: 0] - trigger pointer (pointer where trigger was detected)
     * bits [31:14] - reserved
     */
    uint32_t wr_ptr_trigger;

    /** @brief ChA & ChB hysteresis - both of the format:
     * bits [13: 0] - hysteresis threshold
     * bits [31:14] - reserved
     */
    uint32_t cha_hystersis;
    uint32_t chb_hystersis;

    /** @brief
     * bits [0] - enable signal average at decimation
     * bits [31:1] - reserved
     */
    uint32_t other;

    /** @brief - Pre Trigger counter
     *
     * Pre Trigger counter (offset 0x2C)
     * bits [31: 0] - Pre Trigger counter
     * 32 bit number - how many decimated samples have been stored into a buffer
     * before trigger arrived.
     */
    uint32_t pre_trigger_counter;

    /** @brief ChA Equalization filter
     * bits [17:0] - AA coefficient (pole)
     * bits [31:18] - reserved
     */
    uint32_t cha_filt_aa;

    /** @brief ChA Equalization filter
     * bits [24:0] - BB coefficient (zero)
     * bits [31:25] - reserved
     */
    uint32_t cha_filt_bb;

    /** @brief ChA Equalization filter
     * bits [24:0] - KK coefficient (gain)
     * bits [31:25] - reserved
     */
    uint32_t cha_filt_kk;

    /** @brief ChA Equalization filter
     * bits [24:0] - PP coefficient (pole)
     * bits [31:25] - reserved
     */
    uint32_t cha_filt_pp;

    /** @brief ChB Equalization filter
     * bits [17:0] - AA coefficient (pole)
     * bits [31:18] - reserved
     */
    uint32_t chb_filt_aa;

    /** @brief ChB Equalization filter
     * bits [24:0] - BB coefficient (zero)
     * bits [31:25] - reserved
     */
    uint32_t chb_filt_bb;

    /** @brief ChB Equalization filter
     * bits [24:0] - KK coefficient (gain)
     * bits [31:25] - reserved
     */
    uint32_t chb_filt_kk;

    /** @brief ChB Equalization filter
     * bits [24:0] - PP coefficient (pole)
     * bits [31:25] - reserved
     */
    uint32_t chb_filt_pp;

    /** @brief ChA AXI lower address
    * bits [31:0] - starting writing address
    */
    uint32_t cha_axi_low;

    /** @brief ChA AXI High address
    * bits [31:0] - starting writing address
    */
    uint32_t cha_axi_high;

    /** @brief ChA AXI delay after trigger
    * bits [31:0] - Number of decimated data
    * after trig written into memory
    */
    uint32_t cha_trig_delay;

    /**@brief ChB AXI enable master
    * bits [0] Enable AXI master
    * bits [31:0] reserved
    */
    uint32_t cha_enable_axi_m;

    /**@brief ChA AXI write pointer trigger
    * Write pointer at time the trigger arrived
    */
    uint32_t cha_w_ptr_trig;

    /**@brief ChA AXI write pointer current
    * Current write pointer
    */
    uint32_t cha_w_ptr_curr;

    /* Reserved 0x68 & 0x6C */
    uint32_t reserved_2;
    uint32_t reserved_3;

    /** @brief ChB AXI lower address
    * bits [31:0] - starting writing address
    */
    uint32_t chb_axi_low;

    /** @brief ChB AXI High address
    * bits [31:0] - starting writing address
    */
    uint32_t chb_axi_high;

    /** @brief ChB AXI delay after trigger
    * bits [31:0] - Number of decimated data
    * after trig written into memory
    */
    uint32_t chb_trig_delay;

    /**@brief ChB AXI enable master
    * bits [0] Enable AXI master
    * bits [31:0] reserved
    */
    uint32_t chb_enable_axi_m;

    /**@brief ChB AXI write pointer trigger
    * Write pointer at time the trigger arrived
    */
    uint32_t chb_w_ptr_trig;

    /**@brief ChB AXI write pointer current
    * Current write pointer
    */
    uint32_t chb_w_ptr_curr;

    /* Reserved 0x88 & 0x8C */
    uint32_t reserved_4;
    uint32_t reserved_5;

    /**@brief Trigger debuncer time
    * bits [19:0] Number of ADC clock periods
    * trigger is disabled after activation
    * reset value is decimal 62500
    * or equivalent to 0.5ms
    */
    uint32_t trig_dbc_t;

    /* ChA & ChB data - 14 LSB bits valid starts from 0x10000 and
     * 0x20000 and are each 16k samples long */
} osc_control_t;


#endif