import UIKit

public extension UIFont {
    static func from(
        source: ZTronThemeProvider,
        font: KeyPath<AnyZTronFont, UIFont>
    ) -> UIFont {
        return  source.getTheme().fontSet[keyPath: font]
    }
    
    static func from(
        source: ZTronThemeProvider,
        font: KeyPath<AnyZTronFont, UIFont>,
        weight: UIFont.Weight
    ) -> UIFont {
        return  source.getTheme().fontSet[keyPath: font].withWeight(weight)
    }
    
    static func from<T: ZTronTheme>(
        ztron: T,
        font: KeyPath<T.F, UIFont>,
        weight: UIFont.Weight
    ) -> UIFont {
        return ztron.fontSet[keyPath: font].withWeight(weight)
    }
    
    static func from<T: ZTronTheme>(
        ztron: T,
        font: KeyPath<T.F, UIFont>,
    ) -> UIFont {
        return ztron.fontSet[keyPath: font]
    }
        
    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
            var attributes = fontDescriptor.fontAttributes
            var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

            traits[.weight] = weight

            attributes[.name] = nil
            attributes[.traits] = traits
            attributes[.family] = familyName

            let descriptor = UIFontDescriptor(fontAttributes: attributes)

            return UIFont(descriptor: descriptor, size: pointSize)
        }

}


