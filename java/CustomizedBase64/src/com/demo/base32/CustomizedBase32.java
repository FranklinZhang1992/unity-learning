package com.demo.base32;
import java.util.Arrays;

public class CustomizedBase32 {
	private CustomizedBase32() {
	}

	public static Encoder getEncoder() {
		return Encoder.CUSTOMIZE;
	}

	public static Decoder getDecoder() {
		return Decoder.CUSTOMIZE;
	}

	public static class Encoder {

		static final Encoder CUSTOMIZE = new Encoder();

		private Encoder() {
		}

		private static final char[] toBase32 = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D',
				'E', 'F', 'G', 'H', 'J', 'K', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y' };

		private final int outLength(int srclen) {
			return 8 * ((srclen + 4) / 5);
		}

		public byte[] encode(byte[] src) {
			int len = outLength(src.length);
			byte[] dst = new byte[len];
			int ret = encode0(src, dst);
			if (ret != dst.length)
				return Arrays.copyOf(dst, ret);
			return dst;
		}

		private int encode0(byte[] src, byte[] dst) {
			char[] base32 = toBase32;
			int sp = 0;
			int dp = 0;
			int end = src.length;
			int sl = (end - sp) / 5 * 5;

			while (sp < sl) {
				int bits0 = (src[sp++] & 0xff) << 8 | (src[sp++] & 0xff);
				int bits1 = (src[sp++] & 0xff) << 16 | (src[sp++] & 0xff) << 8 | (src[sp++] & 0xff);

				dst[dp++] = (byte) base32[(bits0 >>> 11) & 0x1f];
				dst[dp++] = (byte) base32[(bits0 >>> 6) & 0x1f];
				dst[dp++] = (byte) base32[(bits0 >>> 1) & 0x1f];
				dst[dp++] = (byte) base32[((bits0 & 0x1) << 4) | ((bits1 >>> 20) & 0xf)];
				dst[dp++] = (byte) base32[(bits1 >>> 15) & 0x1f];
				dst[dp++] = (byte) base32[(bits1 >>> 10) & 0x1f];
				dst[dp++] = (byte) base32[(bits1 >>> 5) & 0x1f];
				dst[dp++] = (byte) base32[bits1 & 0x1f];
			}

			int left = end - sp;
			int b0 = 0;
			int b1 = 0;
			int b2 = 0;
			int b3 = 0;
			if (left > 0) {
				b0 = src[sp++] & 0xff;
				dst[dp++] = (byte) base32[b0 >>> 3];
				if (sp == end) {
					dst[dp++] = (byte) base32[(b0 << 2) & 0x1f];
					dst[dp++] = 'Z';
					dst[dp++] = 'Z';
					dst[dp++] = 'Z';
					dst[dp++] = 'Z';
				}
			}

			if (left > 1) {
				b1 = src[sp++] & 0xff;
				dst[dp++] = (byte) base32[(b0 << 2) & 0x1c | (b1 >>> 6)];
				dst[dp++] = (byte) base32[(b1 >>> 1) & 0x1f];
				if (sp == end) {
					dst[dp++] = (byte) base32[(b1 << 4) & 0x1f];
					dst[dp++] = 'Z';
					dst[dp++] = 'Z';
					dst[dp++] = 'Z';
				}
			}

			if (left > 2) {
				b2 = src[sp++] & 0xff;
				dst[dp++] = (byte) base32[(b1 << 4) & 0x10 | (b2 >>> 4)];
				if (sp == end) {
					dst[dp++] = (byte) base32[(b2 << 1) & 0x1f];
					dst[dp++] = 'Z';
					dst[dp++] = 'Z';
				}
			}

			if (left > 3) {
				b3 = src[sp++] & 0xff;
				dst[dp++] = (byte) base32[(b2 << 1) & 0x1e | (b3 >>> 7)];
				dst[dp++] = (byte) base32[(b3 >>> 2) & 0x1f];
				if (sp == end) {
					dst[dp++] = (byte) base32[(b3 << 3) & 0x1f];
					dst[dp++] = 'Z';
				}
			}

			return dp;
		}

		public String encodeToString(byte[] src) {
			byte[] encoded = encode(src);
			return new String(encoded);
		}
	}

	public static class Decoder {

		private static final int[] fromBase32 = new int[256];
		static {
			Arrays.fill(fromBase32, -1);
			for (int i = 0; i < Encoder.toBase32.length; i++)
				fromBase32[Encoder.toBase32[i]] = i;
			fromBase32['Z'] = -2;
		}

		private Decoder() {
		}

		static final Decoder CUSTOMIZE = new Decoder();

		public byte[] decode(byte[] src) {
			byte[] dst = new byte[outLength(src)];
			int ret = decode0(src, dst);
			if (ret != dst.length) {
				dst = Arrays.copyOf(dst, ret);
			}
			return dst;
		}

		public byte[] decode(String src) {
			return decode(src.getBytes());
		}

		public String decodeToString(String src) {
			return new String(decode(src));
		}

		private int outLength(byte[] src) {
			int paddings = 0;
			int len = src.length;
			if (len == 0)
				return 0;
			if (len < 6) {
				throw new IllegalArgumentException("Input byte[] should at least have 6 bytes for base32 bytes");
			}

			for (int i = len - 1; i >= 0; i--) {
				if (src[i] == 'Z') {
					paddings++;
				}
			}

			return 5 * ((len + 7) / 8) - paddings;
		}

		private int decode0(byte[] src, byte[] dst) {
			int[] base32 = fromBase32;
			int sp = 0;
			int dp = 0;
			int sl = src.length;

			int bits0 = 0;
			int bits1 = 0;
			int initshift = 35;
			int shiftto = initshift;
			while (sp < sl) {
				int b = src[sp++] & 0xff;
				if ((b = base32[b]) < 0) {
					if (b == -2) {
						boolean isAllZ = true;
						for (int i = sp; i < sl; i++) {
							if (src[i] != 'Z')
								isAllZ = false;
						}
						if (isAllZ && shiftto <= 25)
							break;
					}
					throw new IllegalArgumentException("Illegal base32 character " + Integer.toString(src[sp - 1]));
				}

				if (shiftto >= 20) {
					bits0 |= (b << (shiftto - 20));
				} else {
					bits1 |= (b << shiftto);
				}
				shiftto -= 5;
				if (shiftto < 0) {
					dst[dp++] = (byte) (bits0 >>> 12);
					dst[dp++] = (byte) (bits0 >>> 4);
					dst[dp++] = (byte) ((bits0 << 4) & 0xf0 | (bits1 >>> 16));
					dst[dp++] = (byte) (bits1 >>> 8);
					dst[dp++] = (byte) (bits1);
					shiftto = initshift;
					bits0 = 0;
					bits1 = 0;
				}
			}
			if (shiftto == 25) {
				dst[dp++] = (byte) (bits0 >>> 12);
			} else if (shiftto == 15) {
				dst[dp++] = (byte) (bits0 >>> 12);
				dst[dp++] = (byte) (bits0 >>> 4);
			} else if (shiftto == 10) {
				dst[dp++] = (byte) (bits0 >>> 12);
				dst[dp++] = (byte) (bits0 >>> 4);
				dst[dp++] = (byte) ((bits0 << 4) & 0xf0 | (bits1 >>> 16));
			} else if (shiftto == 0) {
				dst[dp++] = (byte) (bits0 >>> 12);
				dst[dp++] = (byte) (bits0 >>> 4);
				dst[dp++] = (byte) ((bits0 << 4) & 0xf0 | (bits1 >>> 16));
				dst[dp++] = (byte) (bits1 >>> 8);
			} else if (shiftto < 35) {
				throw new IllegalArgumentException("Last unit does not have enough valid bits");
			}
			return dp;
		}
	}
}
