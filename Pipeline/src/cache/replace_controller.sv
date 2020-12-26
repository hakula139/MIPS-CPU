`include "cache.svh"
`include "replace_controller.svh"

module replace_controller #(
  parameter SET_SIZE = `CACHE_E
) (
  input                          clk_i,
  input                          rst_i,
  input                          en_i,
  input        [`MODE_WIDTH-1:0] mode_i,
  input        [SET_SIZE-1:0]    valid_line_i,
  input        [SET_SIZE-1:0]    hit_line_i,
  output logic [SET_SIZE-1:0]    out_line_o
);

  int recent_access[SET_SIZE-1:0];
  int access_count[SET_SIZE-1:0];

  // Encoded line number
  int line_write, line_replace;

  logic hit, all_valid;

  assign hit = |hit_line_i;
  assign all_valid = !(~valid_line_i);

  always_comb begin
    line_write = 0;
    foreach (hit_line_i[i]) begin
      if (hit_line_i[i]) line_write = i;
    end
  end

  assign out_line_o = 1 << line_replace;

  always_comb begin
    if (en_i & ~hit) begin
      if (~all_valid) begin
        // Replaces an empty line
        foreach (valid_line_i[i]) begin
          if (~valid_line_i[i]) line_replace = i;
        end
      end else begin
        case (mode_i)
          `LRU: begin
            // LRU, replaces the least recently used line
            foreach (recent_access[i]) begin
              if (recent_access[i] > recent_access[line_replace]) begin
                line_replace = i;
              end
            end
          end
          `RR: begin
            // RR, replaces random line
            line_replace = $urandom(233) % SET_SIZE;
          end
          `LFU: begin
            // LFU, replaces the least frequently used line
            foreach (access_count[i]) begin
              if (access_count[i] < access_count[line_replace]) begin
                line_replace = i;
              end
            end
          end
        endcase
      end
    end
  end

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      recent_access <= '{default:'0};
      access_count <= '{default:'0};
    end else if (en_i & hit) begin
      case (mode_i)
        `LRU: begin
          foreach (recent_access[i]) begin
            recent_access[i] <= (i == line_replace) ? 0 : recent_access[i] + 1;
          end
        end
        `RR: begin
          // Does nothing
        end
        `LFU: begin
          access_count[line_replace] <= access_count[line_replace] + 1;
        end
      endcase
    end
  end

endmodule : replace_controller
