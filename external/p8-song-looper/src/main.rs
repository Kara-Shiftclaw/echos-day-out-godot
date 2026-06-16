use std::{env, io, fs};
use hound::Sample;

const SAMPLES_PER_SPD: u32 = 183;
const SAMPLES_EDGE: u32 = 64;

fn usage() {
    println!("Usage: p8-song-looper <in> <out> -s <start> -e <end> -d <spd>");
    println!("<in>: Input file to use");
    println!("<out>: Output file to write to");
    println!("-s <start>: The start of the loop, in beats");
    println!("-e <end>: The end of the loop, in beats");
    println!("-d <spd>: The PICO-8 spd that the song is written in");
}

fn main() {
    match parse_args() {
        Ok(args) => {
	    if let Err(err) = edit_wav(args) {
	        println!("Got error {err:?}");
	    }
	},
	Err(cmd_err) => {
	    println!("Error parsing input! Got error {cmd_err:?}");
	    usage()
	}
    }
}

fn parse_args() -> Result<Args, CmdErr> {
    let args: Vec<String> = env::args().collect();

    let mut input = None;
    let mut output = None;
    let mut start = None;
    let mut end = None;
    let mut spd = None;

    let mut args_iter = args.into_iter();
    args_iter.next();
    while let Some(arg) = args_iter.next() {
        if arg == "-s" {
	    start = match args_iter.next() {
	        None => Err(CmdErr::MissingArgument(&"start")),
		Some(new_start) => {new_start.parse::<u32>().map_err(CmdErr::nan)}
	    }.map(|v| Some(v))?;
	} else if arg == "-e" {
	    end = match args_iter.next() {
	        None => Err(CmdErr::MissingArgument(&"end")),
		Some(new_start) => {new_start.parse::<u32>().map_err(CmdErr::nan)}
	    }.map(|v| Some(v))?;
	} else if arg == "-d" {
	    spd = match args_iter.next() {
	        None => Err(CmdErr::MissingArgument(&"spd")),
		Some(new_start) => {new_start.parse::<u32>().map_err(CmdErr::nan)}
	    }.map(|v| Some(v))?;
	} else if input.is_none() {
	    input = Some(arg.clone());
	} else if output.is_none() {
	    output = Some(arg.clone());
	} else {
	    println!("Found extra argument {arg}!");
	    return Err(CmdErr::TooManyArguments);
	}
    }

    if let (Some(input), Some(output), Some(start), Some(end), Some(spd)) = (input, output, start, end, spd) {
        Ok(Args {input, output, start, end, spd})
    } else {
        Err(CmdErr::MissingArgument(""))
    }
}

fn edit_wav(args: Args) -> Result<(), CmdErr> {
    let start_sample = beat_to_sample(args.start, args.spd);
    let end_sample = beat_to_sample(args.end, args.spd);

    let file = fs::File::open(args.input).map_err(CmdErr::io)?;
    let input = hound::WavReader::new(io::BufReader::new(file)).map_err(CmdErr::hound)?;
    let mut samples = input.into_samples::<i16>();

    let (before_start, mut samples) = {
        if start_sample < 10 {
	    (vec!(), samples.skip(0))
	} else {
	    let mut skipped_samples = samples.skip((start_sample - SAMPLES_EDGE) as usize);
	    (get_sample_chunk(&mut skipped_samples, SAMPLES_EDGE)?, skipped_samples)
	}
    };
    let into_start = get_sample_chunk(&mut samples, SAMPLES_EDGE)?;
    let middle = get_sample_chunk(&mut samples, end_sample - start_sample - (2 * SAMPLES_EDGE))?;
    let into_end = get_sample_chunk(&mut samples, SAMPLES_EDGE)?;
    let after_end = get_sample_chunk(&mut samples, SAMPLES_EDGE)?;

    let spec = hound::WavSpec {
        channels: 1,
	sample_rate: 22050,
	bits_per_sample: 16,
	sample_format: hound::SampleFormat::Int,
    };
    let mut writer = hound::WavWriter::create(args.output, spec).map_err(CmdErr::hound)?;
    for i in 0 .. after_end.len() {
        writer.write_sample(lerp_sample(after_end[i], into_start[i], i as u32)).map_err(CmdErr::hound)?;
    }
    for sample in middle {
        writer.write_sample(sample).map_err(CmdErr::hound)?;
    }
    for sample in into_end {
    	writer.write_sample(sample).map_err(CmdErr::hound)?;
    }

    writer.finalize().map_err(CmdErr::hound)?;
    Ok(())
}

fn beat_to_sample(start: u32, spd: u32) -> u32 {
  start * spd * SAMPLES_PER_SPD
}

fn get_sample_chunk<S: Sample>(iter: &mut impl Iterator<Item = Result<S, hound::Error>>, num: u32) -> Result<Vec<i16>, CmdErr> {
    let mut results = vec!();
    for _ in 0 .. num {
    	if let Some(sr) = iter.next() {
	    match sr {
	        Ok(sample) => {results.push(sample.as_i16());},
		Err(hound_err) => {return Err(CmdErr::hound(hound_err));}
	    }
	}
    }
    Ok(results)
}

fn lerp_sample(l: i16, r: i16, i: u32) -> i16 {
    return (l as i32 + (r - l) as i32 * i as i32 / SAMPLES_EDGE as i32) as i16
}

#[derive(Debug)]
enum CmdErr {
    NAN(std::num::ParseIntError),
    MissingArgument(&'static str),
    TooManyArguments,
    Io(io::Error),
    Hound(hound::Error),
}

impl CmdErr {
    fn nan(err: std::num::ParseIntError) -> Self {
        Self::NAN(err)
    }

    fn io(err: io::Error) -> Self{
        Self::Io(err)
    }

    fn hound(err: hound::Error) -> Self {
        Self::Hound(err)
    }
}

#[derive(Debug)]
struct Args {
    input: String,
    output: String,
    start: u32,
    end: u32,
    spd: u32,
}