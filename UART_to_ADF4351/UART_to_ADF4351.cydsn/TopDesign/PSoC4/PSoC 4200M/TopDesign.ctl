-- =============================================================================
-- The following directives assign pins to the locations specific for the
-- CY8CKIT-044 kit.
-- =============================================================================

-- === UART (SCB mode) ===
attribute port_location of \UART:rx(0)\ : label is "PORT(7,0)";
attribute port_location of \UART:tx(0)\ : label is "PORT(7,1)";
