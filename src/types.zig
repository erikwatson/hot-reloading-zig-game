pub const Point = struct {
    x: f64,
    y: f64,
};

pub const Line = struct {
    start: Point,
    end: Point,
};

pub const Curve = struct {
    start: Point,
    cp1: Point,
    cp2: Point,
    end: Point,
};
