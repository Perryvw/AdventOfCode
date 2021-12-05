#[derive(PartialEq, Eq, Hash)]
pub struct Point {
    pub x : i32,
    pub y : i32
}

impl std::fmt::Display for Point {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{},{}", self.x, self.y)
    }
}

pub struct LineSegment {
    pub from : Point,
    pub to: Point
}

impl std::fmt::Display for LineSegment {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{} -> {}", self.from, self.to)
    }
}