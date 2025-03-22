fn main() {
    println!("Welcome to Rust CI/CD Workshop!");
    
    let result = add(5, 3);
    println!("5 + 3 = {}", result);
}

/// Adds two numbers together
fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 2), 4);
        assert_eq!(add(10, 5), 15);
        assert_eq!(add(-5, 5), 0);
    }
}
