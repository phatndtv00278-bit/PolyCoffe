<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String ctx = request.getContextPath();
    String resetEmail = (String) session.getAttribute("resetEmail");
    if (resetEmail == null) resetEmail = "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt lại mật khẩu - PolyCoffee</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #5d5a5a, #2f2e2e);
            font-family: Arial, sans-serif;
        }
        .wrap {
            min-height: 100vh;
        }
        .card-box {
            border: none;
            border-radius: 28px;
            padding: 36px;
            background: #f8f5f2;
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
        }
        .btn-coffee {
            background: #8a5a52;
            color: white;
            border: none;
            border-radius: 14px;
            padding: 12px;
        }
        .btn-coffee:hover {
            background: #744842;
            color: white;
        }
        .form-control {
            border-radius: 14px;
            padding: 12px 14px;
        }
    </style>
</head>
<body>
<div class="container wrap d-flex align-items-center justify-content-center">
    <div class="col-md-5">
        <div class="card-box">
            <h2 class="fw-bold mb-4 text-center">Đặt lại mật khẩu</h2>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger rounded-4"><%= request.getAttribute("error") %></div>
            <% } %>

            <% if (request.getAttribute("success") != null) { %>
                <div class="alert alert-success rounded-4"><%= request.getAttribute("success") %></div>
            <% } %>

            <form action="<%= ctx %>/reset-password" method="post">
                <div class="mb-3">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-control" value="<%= resetEmail %>" placeholder="Nhập email" required>
                </div>

                <div class="mb-3">
                    <label class="form-label">Mã xác nhận 6 số</label>
                    <input type="text" name="otp" class="form-control" placeholder="Nhập mã OTP" required>
                </div>

                <div class="mb-3">
                    <label class="form-label">Mật khẩu mới</label>
                    <input type="password" name="newPassword" class="form-control" placeholder="Nhập mật khẩu mới" required>
                </div>

                <div class="mb-3">
                    <label class="form-label">Xác nhận mật khẩu mới</label>
                    <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu mới" required>
                </div>

                <button type="submit" class="btn btn-coffee w-100">Đổi mật khẩu</button>
            </form>

            <div class="text-center mt-3">
                <a href="<%= ctx %>/login" class="text-decoration-none">Quay lại đăng nhập</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>