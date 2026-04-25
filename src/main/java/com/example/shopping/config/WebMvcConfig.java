package com.example.shopping.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        Path sourceImagePath = Paths.get("src", "main", "resources", "static", "image").toAbsolutePath().normalize();
        Path localImagePath = Paths.get("static", "image").toAbsolutePath().normalize();
        registry.addResourceHandler("/image/**")
                .addResourceLocations(
                        "file:" + sourceImagePath.toString() + "/",
                        "file:" + localImagePath.toString() + "/",
                        "classpath:/static/image/"
                );
    }
}
