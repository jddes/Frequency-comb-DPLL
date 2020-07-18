import time
import serial

SYNC_BYTE = (1<<7)

cmd_ids = {
    "SET_GPIOS":    0x1,
    "SET_SPI_DATA": 0x2,
    "SEND_SPI":     0x3
}
UART_PAYLOAD_BITS = 7
UART_PAYLOAD_BITMASK = (0xff - (1<<7))

def set_reg(reg_name, payload):
    """ Payload can be none to write a command only """
    if payload is None:
        return [SYNC_BYTE, cmd_ids[reg_name]]
    else:
        return [SYNC_BYTE, cmd_ids[reg_name]] + send_register_payload(payload)

def send_register_payload(x):
    """ send 7 bits (UART_PAYLOAD_BITS) at a time, 32 bits total """
    # msbs first
    payload_words = [(x >> (4*UART_PAYLOAD_BITS)) & UART_PAYLOAD_BITMASK,
                     (x >> (3*UART_PAYLOAD_BITS)) & UART_PAYLOAD_BITMASK,
                     (x >> (2*UART_PAYLOAD_BITS)) & UART_PAYLOAD_BITMASK,
                     (x >>    UART_PAYLOAD_BITS ) & UART_PAYLOAD_BITMASK,
                     (x                         ) & UART_PAYLOAD_BITMASK]
    return payload_words

def send_spi(data_word, chip_select):
    """ chip_select can have any of the first 4 bits set,
    each being a boolean flag of whether to load the data into that destination or not """
    return (set_reg("SET_GPIOS",    chip_select) + 
            set_reg("SET_SPI_DATA", data_word) + 
            set_reg("SEND_SPI",     None))

def spi_values_to_uart_bytes(data_words, chip_select=1):
    val = []
    for word in data_words:
        val += send_spi(word, chip_select)
    return val

def set_adf4351_1420MHz():
    # config registers taken from Analog Devices' ADF435x Software
    val = []
    val += send_spi(0x8008029, 1)
    val += send_spi(0x4E42, 1)
    val += send_spi(0x4B3, 1)
    val += send_spi(0x9C803C, 1)
    val += send_spi(0x580005, 1)
    
    val += send_spi(0x388018, 1) # R0, must be last I think
    return val

def set_adf4351_1000MHz():
    # config registers taken from Analog Devices' ADF435x Software
    val = []
    val += send_spi(0x8008011, 1)
    val += send_spi(0x4E42, 1)
    val += send_spi(0x4B3, 1)
    val += send_spi(0xAC803C, 1)
    val += send_spi(0x580005, 1)
    
    val += send_spi(0x500000, 1) # R0, must be last I think
    return val


if __name__ == '__main__':
    f = serial.Serial('COM18', 115200, timeout=0)

    # # monkey-patch the write function to also print
    # write_func = f.write
    # def write_wrapper(*args):
    #     print('%s' % repr(args))
    #     write_func(*args)
    # f.write = write_wrapper
    # set_reg(f, "SET_GPIOS", 0xff)

    while 1:
        print("1420")
        val = set_adf4351_1420MHz()
        print(repr(val))
        f.write(bytes(val))
        time.sleep(1)

        print("1000")
        val = set_adf4351_1000MHz()
        print(repr(val))
        f.write(bytes(val))
        time.sleep(1)



    f.flush()
    f.close()

