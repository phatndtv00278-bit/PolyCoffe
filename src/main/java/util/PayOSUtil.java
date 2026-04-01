package util;

import vn.payos.PayOS;

public class PayOSUtil {

    // DÁN KEY THẬT VÀO ĐÂY SAU
    private static final String CLIENT_ID = "d0212c82-dbcd-475a-a690-0796eee13ad0";
    private static final String API_KEY = "994e2baf-73b5-416a-b3b1-29258c5386ab";
    private static final String CHECKSUM_KEY = "2a7671ebd85e149e08ca95116369f74b74ba6c5d967d299d4a9e6f823a9a8db6";

    private static PayOS payOS;

    public static PayOS getPayOS() {
        if (payOS == null) {
            if (CLIENT_ID == null || CLIENT_ID.isBlank()
                    || API_KEY == null || API_KEY.isBlank()
                    || CHECKSUM_KEY == null || CHECKSUM_KEY.isBlank()) {
                throw new RuntimeException("Bạn chưa cấu hình PayOS CLIENT_ID / API_KEY / CHECKSUM_KEY");
            }
            payOS = new PayOS(CLIENT_ID, API_KEY, CHECKSUM_KEY);
        }
        return payOS;
    }
}