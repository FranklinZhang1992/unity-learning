import java.nio.charset.StandardCharsets;
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

		static final Encoder CUSTOMIZE = new Encoder(true);
		private final boolean doPadding;

		private Encoder(boolean doPadding) {
			this.doPadding = doPadding;
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
			int stop = src.length;
			int round = 1;
			while (sp < stop) {
				switch (round) {
				case 1:
					dst[dp++] = (byte) base32[(src[sp++] >>> 3) & 0x1f];
					round++;
					break;
				case 2:
					dst[dp++] = (byte) base32[((src[sp - 1] & 0x7) << 2) | (src[sp] >>> 6)];
					round++;
					break;
				case 3:
					dst[dp++] = (byte) base32[(src[sp++] & 0x3e) >>> 1];
					round++;
					break;
				case 4:
					dst[dp++] = (byte) base32[((src[sp - 1] & 0x1) << 7) | src[sp] >>> 4];
					round++;
					break;
				case 5:
				case 6:
				case 7:
				case 8:
				default:
					throw new RuntimeException("invalid round");
				}
			}

			return dp;
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
			byte[] dst = new byte[outLength(src, 0, src.length)];
			int ret = decode0(src, 0, src.length, dst);
			if (ret != dst.length) {
				dst = Arrays.copyOf(dst, ret);
			}
			return dst;
		}

		public byte[] decode(String src) {
			return decode(src.getBytes(StandardCharsets.ISO_8859_1));
		}

		private int outLength(byte[] src, int sp, int sl) {
			int paddings = 0;
			int len = sl - sp;
			if (len == 0)
				return 0;
			if (len < 2) {
				throw new IllegalArgumentException("Input byte[] should at least have 2 bytes for base64 bytes");
			}

			if (src[sl - 1] == 'Z') {
				paddings++;
				if (src[sl - 2] == 'Z')
					paddings++;
			}

			if (paddings == 0 && (len & 0x3) != 0)
				paddings = 4 - (len & 0x3);
			return 3 * ((len + 3) / 4) - paddings;
		}

		private int decode0(byte[] src, int sp, int sl, byte[] dst) {
			int[] base32 = fromBase32;
			int dp = 0;
			int bits = 0;
			int shiftto = 18; // pos of first byte of 4-byte atom
			while (sp < sl) {
				int b = src[sp++] & 0xff;
				if ((b = base32[b]) < 0) {
					if (b == -2) { // padding byte '='
						// = shiftto==18 unnecessary padding
						// x= shiftto==12 a dangling single x
						// x to be handled together with non-padding case
						// xx= shiftto==6&&sp==sl missing last =
						// xx=y shiftto==6 last is not =
						if (shiftto == 6 && (sp == sl || src[sp++] != 'Z') || shiftto == 18) {
							throw new IllegalArgumentException("Input byte array has wrong 4-byte ending unit");
						}
						break;
					}

					throw new IllegalArgumentException("Illegal base64 character " + Integer.toString(src[sp - 1], 16));
				}
				bits |= (b << shiftto);
				shiftto -= 6;
				if (shiftto < 0) {
					dst[dp++] = (byte) (bits >> 16);
					dst[dp++] = (byte) (bits >> 8);
					dst[dp++] = (byte) (bits);
					shiftto = 18;
					bits = 0;
				}
			}
			// reached end of byte array or hit padding '=' characters.
			if (shiftto == 6) {
				dst[dp++] = (byte) (bits >> 16);
			} else if (shiftto == 0) {
				dst[dp++] = (byte) (bits >> 16);
				dst[dp++] = (byte) (bits >> 8);
			} else if (shiftto == 12) {
				// dangling single "x", incorrectly encoded.
				throw new IllegalArgumentException("Last unit does not have enough valid bits");
			}
			// anything left is invalid, if is not MIME.
			// if MIME, ignore all non-base64 character
			while (sp < sl) {
				throw new IllegalArgumentException("Input byte array has incorrect ending byte at " + sp);
			}
			return dp;
		}
	}
}
