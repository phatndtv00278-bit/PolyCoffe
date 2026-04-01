package util;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;

public class FileUtil {

    public static String save(Part part, ServletContext context, String folderName) throws IOException {
        if (part == null || part.getSize() == 0) {
            return null;
        }

        String originalFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (originalFileName == null || originalFileName.isBlank()) {
            return null;
        }

        String extension = "";
        int dotIndex = originalFileName.lastIndexOf(".");
        if (dotIndex >= 0) {
            extension = originalFileName.substring(dotIndex);
        }

        String newFileName = UUID.randomUUID() + extension;

        String uploadPath = context.getRealPath("") + File.separator + "uploads" + File.separator + folderName;
        File uploadDir = new File(uploadPath);

        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String fullPath = uploadPath + File.separator + newFileName;
        part.write(fullPath);

        return "uploads/" + folderName + "/" + newFileName;
    }

    public static void delete(String relativePath, ServletContext context) {
        if (relativePath == null || relativePath.isBlank()) {
            return;
        }

        String fullPath = context.getRealPath("") + File.separator + relativePath.replace("/", File.separator);
        File file = new File(fullPath);

        if (file.exists()) {
            file.delete();
        }
    }
}