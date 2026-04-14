package com.example.shopping.service;

import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Stream;

@Service
public class ImageAssetService {

    private final Set<String> existingUrls = ConcurrentHashMap.newKeySet();
    private final Map<String, List<String>> urlsByDirectory = new ConcurrentHashMap<>();
    private final Map<String, List<String>> urlsByDirectoryAndStem = new ConcurrentHashMap<>();
    private final Map<String, List<String>> urlsByFileName = new ConcurrentHashMap<>();

    private volatile boolean indexed = false;

    public String resolveImageUrl(String imageUrl) {
        if (imageUrl == null || imageUrl.isBlank()) {
            return null;
        }
        ensureIndexed();

        String normalized = normalizeUrl(imageUrl);
        if (existingUrls.contains(normalized)) {
            return normalized;
        }

        for (Map.Entry<String, String> alias : folderAliases().entrySet()) {
            if (normalized.contains(alias.getKey())) {
                String candidate = normalized.replace(alias.getKey(), alias.getValue());
                if (existingUrls.contains(candidate)) {
                    return candidate;
                }
            }
        }

        String directory = parentDirectory(normalized);
        String stem = fileStem(normalized);
        List<String> sameStem = urlsByDirectoryAndStem.get(directory + "::" + stem);
        if (sameStem != null && !sameStem.isEmpty()) {
            return sameStem.get(0);
        }

        List<String> sameDirectory = urlsByDirectory.get(directory);
        if (sameDirectory != null && !sameDirectory.isEmpty()) {
            return sameDirectory.get(0);
        }

        List<String> sameFileName = urlsByFileName.get(fileName(normalized));
        if (sameFileName != null && sameFileName.size() == 1) {
            return sameFileName.get(0);
        }

        return normalized;
    }

    public List<String> resolveImageUrls(List<String> imageUrls) {
        if (imageUrls == null || imageUrls.isEmpty()) {
            return List.of();
        }
        List<String> resolved = new ArrayList<>();
        for (String imageUrl : imageUrls) {
            String candidate = resolveImageUrl(imageUrl);
            if (candidate != null && !candidate.isBlank() && !resolved.contains(candidate)) {
                resolved.add(candidate);
            }
        }
        return resolved;
    }

    private synchronized void ensureIndexed() {
        if (indexed) {
            return;
        }
        Path root = resolveStaticRoot();
        if (root == null || !Files.isDirectory(root)) {
            indexed = true;
            return;
        }

        try (Stream<Path> stream = Files.walk(root)) {
            stream.filter(Files::isRegularFile)
                    .sorted(Comparator.comparing(Path::toString))
                    .forEach(path -> register(root, path));
        } catch (IOException ignored) {
        }

        indexed = true;
    }

    private void register(Path root, Path file) {
        String relative = root.relativize(file).toString().replace('\\', '/');
        String url = "/image/" + relative;
        existingUrls.add(url);

        String directory = parentDirectory(url);
        String fileName = fileName(url);
        String stem = fileStem(url);

        urlsByDirectory.computeIfAbsent(directory, key -> new ArrayList<>()).add(url);
        urlsByDirectoryAndStem.computeIfAbsent(directory + "::" + stem, key -> new ArrayList<>()).add(url);
        urlsByFileName.computeIfAbsent(fileName, key -> new ArrayList<>()).add(url);
    }

    private Path resolveStaticRoot() {
        Path sourceRoot = Paths.get("src", "main", "resources", "static", "image");
        if (Files.isDirectory(sourceRoot)) {
            return sourceRoot;
        }
        Path localRoot = Paths.get("static", "image");
        if (Files.isDirectory(localRoot)) {
            return localRoot;
        }
        return null;
    }

    private Map<String, String> folderAliases() {
        Map<String, String> aliases = new LinkedHashMap<>();
        aliases.put("/image/appliances/washing/", "/image/appliances/washingMachine/");
        aliases.put("/image/appliances/floorwasher/", "/image/appliances/floorWasher/");
        return aliases;
    }

    private String normalizeUrl(String imageUrl) {
        String normalized = imageUrl.trim().replace('\\', '/');
        if (!normalized.startsWith("/")) {
            normalized = "/" + normalized;
        }
        return normalized;
    }

    private String parentDirectory(String imageUrl) {
        int lastSlash = imageUrl.lastIndexOf('/');
        return lastSlash >= 0 ? imageUrl.substring(0, lastSlash + 1) : "/";
    }

    private String fileName(String imageUrl) {
        int lastSlash = imageUrl.lastIndexOf('/');
        String fileName = lastSlash >= 0 ? imageUrl.substring(lastSlash + 1) : imageUrl;
        return fileName.toLowerCase(Locale.ROOT);
    }

    private String fileStem(String imageUrl) {
        String fileName = fileName(imageUrl);
        int dot = fileName.lastIndexOf('.');
        return dot > 0 ? fileName.substring(0, dot) : fileName;
    }
}
