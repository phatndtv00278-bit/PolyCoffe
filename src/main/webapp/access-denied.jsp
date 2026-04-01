<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Không có quyền truy cập</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #5d5a5a, #2f2e2e);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .box {
            max-width: 520px;
            width: 100%;
            background: #f8f5f2;
            border-radius: 28px;
            padding: 40px;
            text-align: center;
            box-shadow: 0 20px 50px rgba(0,0,0,0.25);
        }
    </style>
</head>
<body>
<div class="box">
    <h1 class="fw-bold mb-3">403</h1>
    <h3 class="mb-3">Bạn không có quyền truy cập</h3>
    <p class="text-secondary">Trang này chỉ dành cho người dùng có quyền phù hợp.</p>
    <a href="home.jsp" class="btn btn-dark rounded-pill px-4">Quay lại trang chủ</a>
</div>
</body>
</html>