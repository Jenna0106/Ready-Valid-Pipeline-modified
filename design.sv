module c #(
    parameter int DATA_W = 32
)(
    input  logic               clk,
    input  logic               rst_n,

    input  logic               in_valid,
    input  logic [DATA_W-1:0]  in_data,

    input  logic               out_ready,
    output logic               out_valid,
    output logic [DATA_W-1:0]  out_data
);

    logic [DATA_W-1:0] data_q;
    logic              full;

    // Internal handshake
    logic accept_in;
    logic accept_out;

    // Combinational control
    always_comb begin
        accept_out = full && out_ready;
        accept_in  = in_valid && (!full || out_ready);
        out_data   = data_q;
        out_valid = full;
    end

    // Storage
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            full   <= 1'b0;
            data_q <= '0;
        end else begin
            case ({accept_in, accept_out})

                // Accept new data
                2'b10: begin
                    data_q <= in_data;
                    full   <= 1'b1;
                end

                // Consume data
                2'b01: begin
                    full <= 1'b0;
                end

                // Replace (consume + accept)
                2'b11: begin
                    data_q <= in_data;
                    full   <= 1'b1;
                end

                // Hold
                default: begin
                    full <= full;
                end
            endcase
        end
    end

endmodule
