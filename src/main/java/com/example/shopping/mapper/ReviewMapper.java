package com.example.shopping.mapper;

import com.example.shopping.entity.Review;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ReviewMapper {
    void insert(Review review);
    Review findById(Long id);
    List<Review> findByProductId(Long productId);
    List<Review> findByUserId(Long userId);
    List<Review> findByMerchantProducts(Long merchantId);
    void updateMerchantReply(Review review);
    Double getAverageRatingByProductId(Long productId);
}
