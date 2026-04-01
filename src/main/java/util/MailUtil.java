package util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;

public class MailUtil {

    private static final String FROM_EMAIL = "phatndtv00278@gmail.com";
    private static final String PASSWORD = "hbfp yenq wled hcga";

    public static boolean sendRegisterSuccessMail(String toEmail, String fullName, String username) {
        String subject = "Đăng ký tài khoản PolyCoffee thành công";
        String content = """
                Xin chào %s,

                Bạn đã đăng ký tài khoản PolyCoffee thành công.

                Thông tin tài khoản của bạn:
                - Username: %s

                Cảm ơn bạn đã sử dụng hệ thống PolyCoffee.

                Trân trọng,
                PolyCoffee
                """.formatted(fullName, username);

        return sendMail(toEmail, subject, content);
    }

    public static boolean sendForgotPasswordOtp(String toEmail, String otpCode) {
        String subject = "Mã xác nhận đặt lại mật khẩu - PolyCoffee";
        String content = """
                Xin chào,

                Bạn vừa yêu cầu đặt lại mật khẩu cho tài khoản PolyCoffee.

                Mã xác nhận của bạn là: %s

                Mã này có hiệu lực trong vài phút.
                Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email.

                Trân trọng,
                PolyCoffee
                """.formatted(otpCode);

        return sendMail(toEmail, subject, content);
    }

    public static boolean sendMail(String toEmail, String subject, String content) {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(content);

            Transport.send(message);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}