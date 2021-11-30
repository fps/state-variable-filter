
module StateVariableFilter

struct CommonProcessingResult
  w
  a
  b
  c1
  c2
end

function process_common(freq, q)
  w = 2.0 * tan(pi * freq)
  a = w / q
  b = w*w
  c1 = (a + b)/(1 + 0.5*a + 0.25 * b)
  c2 = b / (a + b)

  CommonProcessingResult(w, a, b, c1, c2)
end

mutable struct State
  z1
  z2
end

State() = State(0,0)

struct D1D0
  d1
  d0
end

function calculate_d0_high(common)
  1.0 - 0.5 * common.c1 + common.c1 * common.c2 * 0.25
end

function calculate_d1d0_band(common)
  d1_band = 1.0 - common.c2
  d0_band = d1_band * common.c1 * 0.5
  D1D0(d1_band, d0_band)
end

function calculate_d0_low(common)
  common.c1 * common.c2 * 0.25
end

function calculate_lowbandhighpass(s, input_buffer, output_buffer, sample_count, highgain, bandgain, lowgain, freq, q)
    common = process_common(freq, q)

    d0_high = calculate_d0_high(common)
    d1d0_band = calculate_d1d0_band(common)
    d0_low = calculate_d0_low(common)
    
    for sample_index = 1:sample_count
        in = input_buffer[sample_index]
        out = 0

        x = in - s.z1 - s.z2 + 1e-20
        out += highgain * d0_high * x
        out += bandgain * (d1d0_band.d0 * x + d1d0_band.d1 * s.z1)
        s.z2 += common.c2 * s.z1
        out += lowgain * (d0_low * x + s.z2)
        s.z1 += common.c1 * x

        output_buffer[sample_index] = out;
    end
    
    output_buffer
end

#struct lowbandhighpass
#{
#  state s;
#
#  void process(float *input_buffer, float *output_buffer, unsigned int sample_count, const float highgain, const float bandgain, const float lowgain, float freq, float q)
#  {
#      const common_processing_commonult common = process_common(freq, q);
#
#      const float d0_high = calculate_d0_high(common);
#      d1d0 d1d0_band = calculate_d1d0_band(common);
#      const float d0_low = calculate_d0_low(common);
#      
#      for (unsigned int sample_index = 0; sample_index < sample_count; ++sample_index)
#      { 
#        const float in = input_buffer[sample_index];
#        float out = 0;
#
#        const float x = in - s.z1 - s.z2 + 1e-20f;
#        out += highgain * d0_high * x;
#        out += bandgain * (d1d0_band.d0 * x + d1d0_band.d1 * s.z1);
#        s.z2 += common.c2 * s.z1;
#        out += lowgain * (d0_low * x + s.z2);
#        s.z1 += common.c1 * x;
#
#        output_buffer[sample_index] = out;
#      }
#   }
#};
#
#struct highpass
#{
#  state s;
#
#  void process(float *input_buffer, float *output_buffer, unsigned int sample_count, const float highgain, float freq, float q)
#  {
#      const common_processing_commonult common = process_common(freq, q);
#
#      const float d0_high = calculate_d0_high(common);
#      
#      for (unsigned int sample_index = 0; sample_index < sample_count; ++sample_index)
#      { 
#        const float in = input_buffer[sample_index];
#
#        const float x = in - s.z1 - s.z2 + 1e-20f;
#        output_buffer[sample_index] = highgain * d0_high * x;
#        s.z2 += common.c2 * s.z1;
#        s.z1 += common.c1 * x;
#      }
#   }
#};
#
#struct bandpass
#{
#  state s;
#
#  void process(float *input_buffer, float *output_buffer, unsigned int sample_count, const float bandgain, float freq, float q)
#  {
#      const common_processing_commonult common = process_common(freq, q);
#
#      d1d0 d1d0_band = calculate_d1d0_band(common);
#      
#      for (unsigned int sample_index = 0; sample_index < sample_count; ++sample_index)
#      { 
#        const float in = input_buffer[sample_index];
#
#        const float x = in - s.z1 - s.z2 + 1e-20f;
#        output_buffer[sample_index] = bandgain * (d1d0_band.d0 * x + d1d0_band.d1 * s.z1);
#        s.z2 += common.c2 * s.z1;
#        s.z1 += common.c1 * x;
#      }
#   }
#};
#
#struct lowpass
#{
#  state s;
#
#  void process(float *input_buffer, float *output_buffer, unsigned int sample_count, const float lowgain, float freq, float q)
#  {
#      const common_processing_commonult common = process_common(freq, q);
#
#      const float d0_low = calculate_d0_low(common);
#      
#      for (unsigned int sample_index = 0; sample_index < sample_count; ++sample_index)
#      { 
#        const float in = input_buffer[sample_index];
#
#        const float x = in - s.z1 - s.z2 + 1e-20f;
#        s.z2 += common.c2 * s.z1;
#        output_buffer[sample_index] = lowgain * (d0_low * x + s.z2);
#        s.z1 += common.c1 * x;
#      }
#   }
#};
#
#} // namespace
#
##endif
#

end
