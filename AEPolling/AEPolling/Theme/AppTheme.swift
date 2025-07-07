//
//  AppTheme.swift
//  AEPolling
//
//  Created by Marcus O'Shea on 5/26/25.
//

import SwiftUI

// MARK: - App Colors (matching Android theme)
struct AppColors {
    // Primary colors from Android theme
    static let primary = Color(red: 0.278, green: 0.361, blue: 0.424) // #475c6c
    static let secondary = Color(red: 0.804, green: 0.545, blue: 0.384) // #cd8b62
    static let tertiary = Color(red: 0.925, green: 0.851, blue: 0.631) // #ECD9A1
    static let gold = Color(red: 0.753, green: 0.584, blue: 0.157) // #C09528
    
    // Additional colors
    static let black = Color.black
    static let red = Color(red: 0.776, green: 0.157, blue: 0.157) // #C62828
    static let textBoxBackground = Color(red: 0.980, green: 0.980, blue: 0.980) // #FAFAFA
    static let linkBlue = Color(red: 0.247, green: 0.318, blue: 0.710) // #3F51B5
    
    // New colors from screenshots
    static let sandCardBackground = Color(red: 0.925, green: 0.851, blue: 0.631) // #ECD9A1
    static let beigeLightBackground = Color(red: 0.961, green: 0.937, blue: 0.843) // #F5EFD7
    static let checkmarkGreen = Color(red: 0.298, green: 0.686, blue: 0.314) // #4CAF50
}

// MARK: - App Theme
struct AppTheme {
    static let primaryColor = AppColors.primary
    static let secondaryColor = AppColors.secondary
    static let tertiaryColor = AppColors.tertiary
    static let backgroundColor = AppColors.primary
    static let cardBackgroundColor = AppColors.tertiary
    static let textColor = AppColors.black
    static let linkColor = AppColors.linkBlue
    static let successColor = AppColors.checkmarkGreen
    static let errorColor = AppColors.red
}

// MARK: - Color Extensions
extension Color {
    static let appPrimary = AppColors.primary
    static let appSecondary = AppColors.secondary
    static let appTertiary = AppColors.tertiary
    static let appGold = AppColors.gold
    static let appBackground = AppColors.primary
    static let appCardBackground = AppColors.tertiary
    static let appText = AppColors.black
    static let appLink = AppColors.linkBlue
    static let appSuccess = AppColors.checkmarkGreen
    static let appError = AppColors.red
} 