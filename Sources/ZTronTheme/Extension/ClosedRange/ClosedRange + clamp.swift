import Foundation


extension Range {
    func clamp(_ value: Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound :
            self.upperBound < value ? self.upperBound :
            value
    }
}

extension ClosedRange {
    func clamp(_ value: Bound) -> Bound {
        return self.lowerBound >= value ? self.lowerBound :
            self.upperBound <= value ? self.upperBound :
            value
    }
}

