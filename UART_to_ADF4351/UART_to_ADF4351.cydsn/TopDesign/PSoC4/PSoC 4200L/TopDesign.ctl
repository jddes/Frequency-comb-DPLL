-- =============================================================================
-- The following directives assign pins to the locations specific for the
-- CY8CKIT-046 kit.
-- =============================================================================

-- === UART (SCB mode) ===
attribute port_location of \UART:rx(0)\ : label is "PORT(3,0)";
attribute port_location of \UART:tx(0)\ : label is "PORT(3,1)";