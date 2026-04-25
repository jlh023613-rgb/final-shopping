package com.example.shopping.service;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.UUID;

@Service
public class UploadStorageService {

    public String storeImage(MultipartFile file, String folder) throws IOException {
        if (file == null || file.isEmpty()) {
            return null;
        }

        String safeFolder = normalizeFolder(folder);
        String extension = extractExtension(file.getOriginalFilename());
        String fileName = UUID.randomUUID() + extension;

        Path uploadDir = Paths.get("src", "main", "resources", "static", "image", safeFolder)
                .toAbsolutePath()
                .normalize();
        Files.createDirectories(uploadDir);
        Files.copy(file.getInputStream(), uploadDir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);

        return "/image/" + safeFolder + "/" + fileName;
    }

    private String normalizeFolder(String folder) {
        if (folder == null || folder.isBlank()) {
            return "misc";
        }
        return folder.replace("\\", "/").replaceAll("^/+", "").replaceAll("/+$", "");
    }

    private String extractExtension(String originalFilename) {
        if (originalFilename == null || originalFilename.isBlank()) {
            return ".png";
        }
        int dotIndex = originalFilename.lastIndexOf('.');
        if (dotIndex < 0 || dotIndex == originalFilename.length() - 1) {
            return ".png";
        }
        String extension = originalFilename.substring(dotIndex).toLowerCase(Locale.ROOT);
        if (!extension.matches("\\.(jpg|jpeg|png|gif|webp|bmp)$")) {
            return ".png";
        }
        return extension;
    }
}
