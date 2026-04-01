<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký - PolyCoffee</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #5d5a5a, #2f2e2e);
            font-family: Arial, sans-serif;
        }
        .auth-wrapper {
            min-height: 100vh;
        }
        .auth-card {
            border: none;
            border-radius: 28px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
        }
        .auth-left {
            background: linear-gradient(135deg, #8a5a52, #6f4b44);
            color: white;
            padding: 48px;
        }
        .auth-right {
            background: #f8f5f2;
            padding: 40px;
        }
        .brand-circle {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            background: rgba(255,255,255,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            margin-bottom: 24px;
        }
        .form-control {
            border-radius: 14px;
            padding: 12px 14px;
        }
        .btn-coffee {
            background: #8a5a52;
            color: white;
            border-radius: 14px;
            padding: 12px;
            border: none;
        }
        .btn-coffee:hover {
            background: #744842;
            color: white;
        }
        .input-group-text {
            border-radius: 14px 0 0 14px;
        }
        .password-toggle {
            cursor: pointer;
        }
    </style>
</head>
<body>
<div class="container auth-wrapper d-flex align-items-center justify-content-center py-5">
    <div class="col-lg-11">
        <div class="card auth-card">
            <div class="row g-0">
                <div class="col-lg-5 auth-left d-flex flex-column justify-content-center">
                    <div class="brand-circle">
                        <i class="bi bi-cup-hot"></i>
                    </div>
                    <h5 class="mb-2">Tạo tài khoản mới</h5>
                    <h1 class="fw-bold mb-3">Join PolyCoffee</h1>
                    <p class="mb-0">
                        Đăng ký để bắt đầu sử dụng hệ thống quản lý quán cafe với giao diện đẹp và trải nghiệm hiện đại.
                    </p>
                </div>

                <div class="col-lg-7 auth-right">
                    <h2 class="fw-bold mb-4">Đăng ký</h2>

                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger rounded-4">${error}</div>
                    <% } %>

                    <form action="register" method="post">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Họ và tên</label>
                                <input type="text" name="fullName" class="form-control" placeholder="Nhập họ tên" required>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Email</label>
                                <input type="email" name="email" class="form-control" placeholder="Nhập email" required>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Tên đăng nhập</label>
                                <input type="text" name="username" class="form-control" placeholder="Nhập username" required>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Mật khẩu</label>
                                <div class="input-group">
                                    <input type="password" name="password" id="password" class="form-control" placeholder="Nhập mật khẩu" required>
                                    <span class="input-group-text password-toggle" onclick="togglePassword('password', this)">
                                        <i class="bi bi-eye"></i>
                                    </span>
                                </div>
                            </div>

                            <div class="col-12 mb-4">
                                <label class="form-label">Xác nhận mật khẩu</label>
                                <div class="input-group">
                                    <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu" required>
                                    <span class="input-group-text password-toggle" onclick="togglePassword('confirmPassword', this)">
                                        <i class="bi bi-eye"></i>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-coffee w-100">Tạo tài khoản</button>
                    </form>

                    <p class="mt-4 mb-0 text-center">
                        Đã có tài khoản?
                        <a href="login" class="text-decoration-none fw-semibold">Đăng nhập</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function togglePassword(id, el) {
        const input = document.getElementById(id);
        const icon = el.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'bi bi-eye-slash';
        } else {
            input.type = 'password';
            icon.className = 'bi bi-eye';
        }
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>