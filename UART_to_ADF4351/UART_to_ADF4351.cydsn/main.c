/*******************************************************************************
* File Name: main.c
*
* Version: 1.20
*
* Description:
*  This example project demonstrates the basic operation of the SCB component
*  in the UART mode. The polling method is used to wait for received character.
*  As soon as character is received it is transmitted back. The serial terminal
*  can be used on the PC to send characters and get them back.
*  The example will echo every received character.
*
********************************************************************************
* Copyright 2014-2015, Cypress Semiconductor Corporation. All rights reserved.
* This software is owned by Cypress Semiconductor Corporation and is protected
* by and subject to worldwide patent and copyright laws and treaties.
* Therefore, you may use this software only as provided in the license agreement
* accompanying the software package from which you obtained this software.
* CYPRESS AND ITS SUPPLIERS MAKE NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
* WITH REGARD TO THIS SOFTWARE, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT,
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
*******************************************************************************/

#include <project.h>

void led_flag_error();
void led_flag_ack();
void set_gpios(uint8 val);
void send_spi(uint32 word);

#define STATE_WAIT_FOR_SYNC   0
#define STATE_WAIT_FOR_CMD_ID 1
#define STATE_SET_REG1 2
#define STATE_SET_REG2 3
#define STATE_SET_REG3 4
#define STATE_SET_REG4 5
#define STATE_SET_REG5 6

uint32 uart_decoder_state = STATE_WAIT_FOR_SYNC;

#define UART_PAYLOAD_BITS 7
#define UART_PAYLOAD_BITMASK (0xff - (1<<7))
#define GET_BIT(x, n) ((x>>n)&0x1)

uint32 selector_gpios = 0;
uint32 spi_data_reg = 0;
#define CMD_ID_SET_GPIOS 0x1
#define CMD_ID_SET_SPI_DATA 0x2
#define CMD_ID_SEND_SPI 0x3

// this is half the serial port's period, in microseconds
#define SERIAL_DELAY 10

void send_spi(uint32 word)
{
    uint32 word_reg = word;
    uint32 k=0;
    
    Pin_SCLK_Write(0);
    set_gpios(0);
    CyDelayUs(SERIAL_DELAY);
    
    for (k=0; k<32; k++)
    {
        Pin_SDATA_Write((word_reg >> 31) & 0x1); // write the msb
        CyDelayUs(SERIAL_DELAY);
        Pin_SCLK_Write(1);
        CyDelayUs(SERIAL_DELAY);
        Pin_SCLK_Write(0);
        
        word_reg = word_reg << 1;
    }
    
    
    // strobe the chip select pin(s)
    set_gpios(1);
    CyDelayUs(SERIAL_DELAY);
    set_gpios(0);
    CyDelayUs(SERIAL_DELAY);
}



void set_gpios(uint8 val)
{
    if (GET_BIT(selector_gpios, 0))
        Pin_Sel_1_Write(val);
    if (GET_BIT(selector_gpios, 1))
        Pin_Sel_2_Write(val);
    if (GET_BIT(selector_gpios, 2))
        Pin_Sel_3_Write(val);
    if (GET_BIT(selector_gpios, 3))
        Pin_Sel_4_Write(val);
}

uint8 uart_bytes_all[255];

int main()
{
    uint16 uart_response;
    // uint32 count = 0;
    uint8 uart_byte;
    uint8 uart_status;
    uint32* target_reg;
    uint32 temp_reg;
    uint32 byte_count=0;

    /* Enable global interrupts */
    CyGlobalIntEnable;
    
    /* Start SCB (UART mode) operation */
    UART_Start();
    UART_ClearRxBuffer();
    
    //send_spi(0xff);
    led_flag_ack();
    
    
    for (;;)
    {
        /* Get received character or zero if nothing has been received yet */
        //uart_response = UART_GetByte();        
        
        uart_status = UART_ReadRxStatus();
        if (uart_status != UART_RX_STS_FIFO_NOTEMPTY)
        {
            // this could be as simple as we have tried to read an empty buffer
            // we don't even bother checking what the error code is and just keep retrying
            continue;
        }
        uart_byte = UART_ReadRxData();
        if (byte_count < 255)
            uart_bytes_all[byte_count++] = uart_byte;
        // uart_byte = uart_response & 0xff;
        //UART_PutChar(uart_byte);
        //led_flag_ack();
        //CyDelay(100);
        if (uart_byte & (1<<7))
        {
            // this is the sync code: it is supposed to be absent from the data payloads,
            // and is reserved for resyncing of the bus.
            // it is expected as the start of every transaction,
            // but not anywhere else within the transaction
            if (uart_decoder_state != STATE_WAIT_FOR_SYNC)
            {
                // this is an error condition; we still handle gracefully, but flag the error through the LED
                uart_decoder_state = STATE_WAIT_FOR_CMD_ID;
                //UART_UartPutString("Unexpected sync\r\n");
                // led_flag_error();
            } else {
                // normal case:
                uart_decoder_state = STATE_WAIT_FOR_CMD_ID;
                //UART_UartPutString("Recvd proper sync\r\n");
                // led_flag_ack();
            }
            continue;
        }

        switch (uart_decoder_state)
        {
            case STATE_WAIT_FOR_CMD_ID:
                switch (uart_byte)
                {
                    case CMD_ID_SET_GPIOS:
                        target_reg = &selector_gpios;
                        uart_decoder_state = STATE_SET_REG1;
                        //UART_UartPutString("Recvd CMD_ID_SET_NUMBER_OF_STEPS\r\n");
                        break;
                    
                    case CMD_ID_SET_SPI_DATA:
                        target_reg = &spi_data_reg;
                        uart_decoder_state = STATE_SET_REG1;
                        //UART_UartPutString("Recvd CMD_ID_SET_STEPS_DURATION\r\n");
                        break;
                    
                    case CMD_ID_SEND_SPI:
                        send_spi(spi_data_reg);
                        // UART_PutChar(0x1); // ack that the forward steps are done
                        uart_decoder_state = STATE_WAIT_FOR_SYNC;
                        //UART_UartPutString("Recvd CMD_ID_STEP_FORWARD\r\n");
                        break;
                        
                        
                    default:
                        // this is an error condition
                        led_flag_error();
                        uart_decoder_state = STATE_WAIT_FOR_SYNC;
                        //UART_UartPutString("Recvd unknown CMD_ID:");
                        //UART_PutChar(uart_byte);
                        //UART_UartPutString("\r\n");
                }
                break;

           case STATE_SET_REG1:
                temp_reg = uart_byte & UART_PAYLOAD_BITMASK;
                uart_decoder_state = STATE_SET_REG2;
                break;

           case STATE_SET_REG2:
                temp_reg = (temp_reg<<UART_PAYLOAD_BITS) | (uart_byte & UART_PAYLOAD_BITMASK);
                uart_decoder_state = STATE_SET_REG3;
                break;
                
           case STATE_SET_REG3:
                temp_reg = (temp_reg<<UART_PAYLOAD_BITS) | (uart_byte & UART_PAYLOAD_BITMASK);
                uart_decoder_state = STATE_SET_REG4;
                break;
                
           case STATE_SET_REG4:
                temp_reg = (temp_reg<<UART_PAYLOAD_BITS) | (uart_byte & UART_PAYLOAD_BITMASK);
                uart_decoder_state = STATE_SET_REG5;
                break;
                
           case STATE_SET_REG5:
                temp_reg = (temp_reg<<UART_PAYLOAD_BITS) | (uart_byte & UART_PAYLOAD_BITMASK);
                *target_reg = temp_reg;
                uart_decoder_state = STATE_WAIT_FOR_SYNC;
                break;
                
        }
        
    }
}


void led_flag_error()
{
    Pin_LED_Write(0x1);
    CyDelay(100);
    Pin_LED_Write(0x0);
    CyDelay(100);
}

void led_flag_ack()
{
    Pin_LED_Write(0x1);
    CyDelay(10);
    Pin_LED_Write(0x0);
    CyDelay(100);
}



/* [] END OF FILE */
