-- =============================================================================
-- The following directives assign pins to the locations specific for the
-- CY8CKIT-048 kit.
-- =============================================================================

-- === UART (SCB mode) ===
attribute port_location of \UART:rx(0)\ : label is "PORT(0,4)";
attribute port_location of \UART:tx(0)\ : label is "PORT(0,5)";