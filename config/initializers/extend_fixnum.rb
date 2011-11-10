# -*- encoding : utf-8 -*-
class Fixnum
  LONG_MAX = ( (2 ** (64 - 2)) - 1 )
  INT_MAX = ( (2 ** (32 - 2)) - 1 )

  if LONG_MAX.class == Fixnum
    N_BYTES = 8
    N_BITS = 64
    MAX = LONG_MAX
    MIN = -MAX - 1
  else
    N_BYTES = 4
    N_BITS = 32 
    MAX = INT_MAX
    MIN = -MAX - 1
  end
end
