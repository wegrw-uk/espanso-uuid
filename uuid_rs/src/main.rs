//! A simple CLI utility to generate UUIDv4 and UUIDv7 strings.
//!
//! This utility is designed to be called by Espanso to provide fast,
//! dependency-free UUID generation.

use std::process;
use uuid::Uuid;

fn main() {
    let mode = std::env::args().nth(1).unwrap_or_else(|| "7".to_string());

    let u = match mode.as_str() {
        "7" | "v7" | "uuid7" => Uuid::now_v7(),
        "4" | "v4" | "uuid4" => Uuid::new_v4(),
        "-h" | "--help" => {
            println!("Usage: espanso-uuid7-rs [4|7]");
            process::exit(0);
        }
        _ => {
            eprintln!("Unsupported UUID version '{}'. Use 4 or 7.", mode);
            process::exit(2);
        }
    };

    // Use print! to avoid injecting an unwanted "Enter" keystroke
    print!("{}", u);
}
