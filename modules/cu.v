// CU - Control Unit
// This is responsible for actually creating a runtime for instructions
// Providing for things like states n such, just think of it as a giant state-machine of logical inputs

module CU(
        // Control Unit Specific
        input Clock, Reset, Stop, Clear,
        output reg Run,
        
        // Register selector
        output reg Gra, Grb, Grc,
        output reg BAout, Rin, Rout,
        output reg Cout, // for the C_sign_extended for immediates
    )
endmodule