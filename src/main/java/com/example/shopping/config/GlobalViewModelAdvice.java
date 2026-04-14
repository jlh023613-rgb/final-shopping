package com.example.shopping.config;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalViewModelAdvice {

    @ModelAttribute
    public void addRequestUri(HttpServletRequest request, Model model) {
        if (request != null) {
            model.addAttribute("requestUri", request.getRequestURI());
        }
    }
}
