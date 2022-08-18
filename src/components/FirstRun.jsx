import React from 'react';

import {
    Box,
    Button,
    Typography,
    Fade,
    Grow,
    Zoom,
    CircularProgress,
    Slide,
    Fab
} from '@mui/material';
import ArrowForwardIcon from '@mui/icons-material/ArrowForward';
import Console from '@haensl/react-component-console';
import { SearchAppBar } from './Search.jsx';

import { useDelayUnmount, theme } from '../common';

const boxStyle = {
    position: 'absolute',
    width: '400px',
    height: '50%',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    backgroundColor: '#444444',
    boxShadow: 3,
    borderRadius: "8px",
    padding: "24px",
    display: 'grid',
    placeItems: 'center',
    overflow: 'hidden',
    maxWidth: '600px',
    overflowWrap: 'anywhere'
};

function FirstRunPageOne (props) {
    const [isMounted, setIsMounted] = React.useState(false);
    const container = React.createRef();

    React.useEffect(() => {
        setIsMounted(true);
        return () => {
            setIsMounted(false);
        }
    }, []);

    const handleNext = () => {
        setIsMounted(false);
        setTimeout(props.handleNext, 600);
    }

    return (<Fade in={isMounted} timeout={600}><Box sx={boxStyle}>
        <Typography variant="h2">Darvester</Typography>
        <Typography variant="body">The only Discord OSINT utility you'll ever need</Typography>
        <Slide direction="up" in={true} container={container.current} timeout={400}>
            <Fab
                aria-label="next"
                color="primary"
                onClick={handleNext}
            >
                <ArrowForwardIcon />
            </Fab>
        </Slide>
    </Box></Fade>)
}

function FirstRunPageTwo (props) {
    const [isMounted, setIsMounted] = React.useState(false);

    React.useEffect(() => {
        setIsMounted(true);
        return () => {
            setIsMounted(false);
        }
    }, []);

    const handleNext = () => {
        setIsMounted(false);
        setTimeout(props.handleNext, 600);
    }

    return (
        <Fade in={isMounted} timeout={600}>
            <Box sx={boxStyle}>
                <Typography variant="h4">
                    Checking if Python is installed...
                </Typography>
                {props.pythonFound === null ? <CircularProgress /> : <Typography variant="body">{
                    props.error.error ? `Error: ${props.error.message}` : `Found supported Python ${props.pythonVersion[0]}.${props.pythonVersion[1]}`}</Typography>
                }
                {!props.error.error && props.pythonFound ? <>
                    <Fade in={!!props.pythonFound} timeout={400}>
                        <Fab
                            aria-label="next"
                            color="primary"
                            onClick={handleNext}
                        >
                            <ArrowForwardIcon />
                        </Fab>
                    </Fade>
                    </> : null}
            </Box>
        </Fade>
    )
}

function FirstRunPageThree(props) {
    const [isMounted, setIsMounted] = React.useState(false);
    const [isInstalling, setIsInstalling] = React.useState(false);
    const [isInstalled, setIsInstalled] = React.useState(false);
    const [isError, setIsError] = React.useState(false);
    const [venvPath, setVenvPath] = React.useState('');
    const [consoleLines, setConsoleLines] = React.useState(["Installing Python venv..."]);
    const container = React.createRef();
    const nextButton = React.createRef();

    React.useEffect(() => {
        window.electronAPI.getConfigKey('pythonEnv').then((result) => {
            setVenvPath(result);
        });
        setIsMounted(true);
        return () => {
            setIsMounted(false);
        }
    }, []);

    React.useEffect(() => {
        setIsMounted(true);
    }, [venvPath])

    const handleNext = () => {
        setIsMounted(false);
        setTimeout(props.handleNext, 700);
    }

    const handleVenvCreate = () => {
        setIsInstalling(true);
        setTimeout(() => {window.electronAPI.createPythonVenv(venvPath).then((result) => {
            console.log("handleVenvCreate", result);
            if (result.error) {
                setConsoleLines([...consoleLines, "Error: " + result.message]);
                setIsInstalling(false);
                setIsError(true);
            } else {
                setConsoleLines([...consoleLines, result.message]);
                if (result.hasOwnProperty("done") && result.done) {
                    setIsInstalled(true);
                    setIsInstalling(false);
                }
            }
        })}, 2000);
    }

    return (<Fade in={isMounted}>
        <Box sx={{
            ...boxStyle,
            display: 'block',
        }} ref={container} className={`first_run_box frb_bigger`}>
            <Grow in={isMounted} style={{ transformOrigin: '0 0 0' }} timeout={700} easing={{
                enter: theme.transitions.easing.easeOut
            }}>
                <Typography variant="h4">Virtual Environment Setup</Typography>
            </Grow>
            <Grow in={!isInstalling && !isInstalled} style={{ transformOrigin: '0 0 0' }} timeout={700} easing={{
                enter: theme.transitions.easing.easeOut
            }}>
                <Typography variant="body1">Darvester needs to create a Python virtual environment before it can continue. We'll create it at:</Typography>
            </Grow>
            <Grow in={!isInstalling && !isInstalled} style={{ transformOrigin: '0 0 0' }} timeout={700} easing={{
                enter: theme.transitions.easing.easeOut
            }}>
                <pre>{venvPath}</pre>
            </Grow>
            <Grow in={isMounted && (!isInstalling && !isError)} style={{ transformOrigin: '0 0 0' }} timeout={700} easing={{
                enter: theme.transitions.create('all', {
                    duration: 700,
                    easing: theme.transitions.easing.easeOut,
                    delay: 1000
                })
            }}>
                <Fab
                    aria-label="next"
                    color="primary"
                    onClick={!isInstalled ? handleVenvCreate : handleNext}
                    sx={{
                        position: 'absolute',
                        bottom: '24px',
                        right: '24px'
                    }}
                    ref={nextButton}
                >
                    <ArrowForwardIcon />
                </Fab>
            </Grow>
            <Grow in={isInstalling || isInstalled || isError} style={{ transformOrigin: '0 0 0' }} timeout={700} easing={{
                enter: theme.transitions.create('all', {
                    duration: 700,
                    easing: theme.transitions.easing.easeOut,
                    delay: 1000
                })
            }}>
                <div>
                    {(isInstalling || isInstalled || isError) && <Console lines={consoleLines} console={{
                        append: true,
                        typing: {
                            char: {
                                avgMs: 40,
                                deviation: 0.4,
                                minMs: 20
                            },
                            line: {
                                avgMs: 30,
                                deviation: 0.5,
                                minMs: 10
                            }
                        }
                    }} />}
                </div>
            </Grow>
        </Box>
    </Fade>)
}

function TerminalOutput(props) {
    const [lines, setLines] = React.useState([]);
    const div_ref = React.useRef(null);

    React.useEffect(() => {
        if (lines === props.line) {
            setLines(lines);
        } else {
            setLines([...lines, props.line]);
        }
    }, [props.line]);

    React.useEffect(() => {
        div_ref.current.scrollIntoView({ behavior: 'smooth' });
    }, [lines]);

    return (
        <pre>{lines.map(line => <>{line}<br /></>)}<div style={{
            float: "left",
            clear: "both"
        }} ref={div_ref}></div></pre>
    );
}

function FirstRunPageFour(props) {
    const [isMounted, setIsMounted] = React.useState(false);
    const [consoleLines, setConsoleLines] = React.useState([]);
    const [isInstalling, setIsInstalling] = React.useState(false);
    const [isDone, setIsDone] = React.useState(false);

    React.useEffect(() => {
        setIsMounted(true);
        return () => {
            setIsMounted(false);
        }
    }, []);

    const handleNext = () => {
        setIsMounted(false);
        setTimeout(props.handleNext, 600);
    }

    return (
        <Fade in={isMounted}>
            <Box sx={{...boxStyle, display: 'block'}} className={`first_run_box frb_bigger`}>
                <Grow in={isMounted} style={{ transformOrigin: '0 0 0' }} timeout={700} easing={{
                        enter: theme.transitions.create('all', {
                        duration: 700,
                        easing: theme.transitions.easing.easeOut,
                        delay: 1000
                    })
                }}>
                    <Typography variant="h4">Darvester Backend Setup</Typography>
                </Grow>
                <br />
                <Typography variant="body1">
                    We're almost done, but before we get to harvesting, we need to set up the backend. Here, we'll install Python package requirements with pip.
                </Typography>
                <Button onClick={() => {
                    setConsoleLines(['Installing dependencies...']);
                    setIsInstalling(true);
                    window.electronAPI.getConfigKey('pythonEnv').then((data) => {
                        window.electronAPI.installPythonRequirements(data).then((_venv_status) => {
                            window.electronAPI.onVenvStatus((_event, status) => {
                                setConsoleLines([...consoleLines, status.message]);
                                if (status.closed) setIsDone(true);
                            });
                        });
                    });
                }} disabled={isInstalling}>Install</Button>
                {isInstalling && <TerminalOutput line={consoleLines} />}
                <Grow in={isMounted && isDone} style={{ transformOrigin: '0 0 0' }} timeout={700} easing={{
                    enter: theme.transitions.create('all', {
                        duration: 700,
                        easing: theme.transitions.easing.easeOut,
                        delay: 1000
                    })
                }}>
                    <Fab
                        aria-label="next"
                        color="primary"
                        onClick={isDone ? handleNext : null}
                        sx={{
                            position: 'absolute',
                            bottom: '24px',
                            right: '24px'
                        }}
                    >
                        <ArrowForwardIcon />
                    </Fab>
                </Grow>
            </Box>
        </Fade>
    )
}

function FirstRunPageFive(props) {
    const [isMounted, setIsMounted] = React.useState(false);
    const container = React.createRef();

    React.useEffect(() => {
        setIsMounted(true);
        return () => {
            setIsMounted(false);
        }
    }, []);

    const handleNext = () => {
        setIsMounted(false);
        setTimeout(props.handleNext, 600);
    }

    return (
        <Fade in={isMounted} timeout={600}><Box sx={boxStyle}>
        <Typography variant="h2">We're done!</Typography>
        <Typography variant="body">Setup is complete. Let's get to harvesting.</Typography>
        <Slide direction="up" in={true} container={container.current} timeout={400}>
            <Fab
                aria-label="next"
                color="primary"
                onClick={handleNext}
            >
                <ArrowForwardIcon />
            </Fab>
        </Slide>
    </Box></Fade>
    )
}

function FirstRun() {
    const [open, setOpen] = React.useState(true);
    const [progress, setProgress] = React.useState(0);
    const [page, setPage] = React.useState(1);
    const [pythonFound, setPythonFound] = React.useState(null);
    const [pythonVersion, setPythonVersion] = React.useState(null);
    const [error, setError] = React.useState({error: false, message: ''});

    const shouldRender = useDelayUnmount(open, 2000);

    const checkForPython = () => {
        window.electronAPI.askPythonVersion().then((result) => {
            if (result.found) {
                setPythonFound(true);
                setPythonVersion(result.version);
            } else {
                setPythonFound(false);
                setError({error: true, message: result.message});
            }
        });
    }

    const handleNext = () => {
        if (page === 1) {
            checkForPython();
        }
        setProgress(progress + 10);
        setPage(page + 1);
    }

    React.useEffect(() => {
        setOpen(true);
        return () => {
            setOpen(false);
        }
    }, [])

    const pages = () => {
        switch (page) {
            case 1:
                return (<FirstRunPageOne handleNext={handleNext} />);
            case 2:
                return (<FirstRunPageTwo pythonFound={pythonFound} error={error} pythonVersion={pythonVersion} handleNext={handleNext} />)
            case 3:
                return (<FirstRunPageThree handleNext={handleNext} />)
            case 4:
                return (<FirstRunPageFour handleNext={handleNext} />)
            case 5:
                return (<FirstRunPageFive handleNext={handleNext} />)
            case 6:
                return (<SearchAppBar />)
            default: return (<p>Hi, you shouldn't be here. Please report this as a bug</p>);
        }
    }

    return (
        <Fade in={true} timeout={1000}>
            <Box sx={{
                overflow: 'hidden'
            }}>
                {shouldRender ? pages() : null}
            </Box>
        </Fade>
    )
}

export function Boot() {
    const [progress, setProgress] = React.useState(0);

    React.useEffect(() => {
        setProgress(50);

        return () => {
            setProgress(100);
        }
    }, [])

    return (
        <Fade in={true} timeout={1000}>
            <Box sx={boxStyle}>
                <Zoom {...(progress === 100 ? {out: true} : {in: true})} timeout={600}>
                    <Typography variant="body" component="p" textAlign="center" fontSize="1.7rem">Darvester</Typography>
                </Zoom>
                {/* <Typography variant="h3" component="p" textAlign="center">Darvester</Typography> */}
                <Grow in={true} timeout={1000} style={{ transformOrigin: '0 0 0' }}>
                    <img src="darvester_1-1.png" alt="" width="200px" />
                </Grow>
                <Zoom in={true} timeout={2000}>
                    <CircularProgress size="3rem" />
                </Zoom>
            </Box>
        </Fade>
    )
}

export default FirstRun;
