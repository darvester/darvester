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

import StatusIndicator from './Status';

export default function Manager() {
    const [isMounted, setIsMounted] = React.useState(false);

    React.useEffect(() => {
        setIsMounted(true);
        return () => {
            setIsMounted(false);
        }
    }, []);

    const [coreStatus, setCoreStatus] = React.useState({
        changing: false,
        status: 'offline'
    });

    const [apiStatus, setapiStatus] = React.useState({
        changing: false,
        status: 'offline'
    });

    const parseStatus = (status) => {
        switch (status) {
            case 'online':
                return 'online';
            case 'stopped':
                return 'offline';
            case 'errored':
                return 'dnd';
            default:
                return 'idle';
        }
    }

    window.electronAPI.onGetStatus(
        (_event, status) => {
            if (status.error) {
                console.log(status.error);
                return
            }
            status.message.filter((proc) => {
                return ["davester-api", "darvester-core"].includes(proc.name);
            }).forEach(element => {
                if (element.name === "darvester-core") {
                    setCoreStatus({
                        changing: ["stopping", "launching"].includes(element.pm2_env.status),
                        status: parseStatus(status)
                    });
                } else if (element.name === "darvester-api") {
                    setapiStatus({
                        changing: ["stopping", "launching"].includes(element.pm2_env.status),
                        status: parseStatus(status)
                    });
                }
            });
        }
    );

    window.electronAPI.getStatus().then(() => {});

    return (
        <Box>
            <Grow in={isMounted} timeout={1000} style={{ transformOrigin: '0 0 0' }}><Fade in={isMounted} timeout={600}><Typography variant="h2" align='center' sx={{ padding: '20px' }}>Manager</Typography></Fade></Grow>
            <Typography variant="h5" sx={{ paddingLeft: '20px' }}>Processes:</Typography>
            <Grow in={isMounted} timeout={1250} style={{ transformOrigin: '0 0 0' }}><Fade in={isMounted} timeout={900}><Box sx={{
                margin: '20px',
                padding: '20px',
                backgroundColor: '#444444',
                borderRadius: '6px',
                width: 'fit-content',
                minWidth: '300px',
            }}>
                <Box>
                    <Typography variant="h5">Darvester (Core)<StatusIndicator status={coreStatus.status} style={{
                        position: 'relative',
                        top: 0,
                        left: 0,
                        transform: 'none',
                        border: 'none',
                        margin: '4px',
                        marginRight: '12px'
                        }} /></Typography>
                    <Typography variant="body1"><i>Status:</i> {coreStatus.status}</Typography>
                    <Box component="div" sx={{ display: 'inline', padding: '12px', textAlign: 'center' }}>
                        <Button variant="outlined" sx={{ margin: '8px 12px -4px'}} onClick={() => {
                            window.electronAPI.startCore().then(() => {
                                window.electronAPI.onCoreStatus((_event, status) => {
                                    if (status.error) {
                                        console.log(status.message)
                                    }
                                    setCoreStatus({
                                        changing: ["stopping", "launching"].includes(status.message.pm2_env.status),
                                        status: parseStatus(status.message.pm2_env.status)
                                    });
                                });
                            });
                        }}>Start</Button>
                        <Button variant="outlined" sx={{ margin: '8px 12px -4px'}}>Stop</Button>
                    </Box>
                </Box>
            </Box></Fade></Grow>
            <Grow in={isMounted} timeout={1500} style={{ transformOrigin: '0 0 0' }}><Fade in={isMounted} timeout={1200}><Box sx={{
                margin: '20px',
                padding: '20px',
                backgroundColor: '#444444',
                borderRadius: '6px',
                width: 'fit-content',
                minWidth: '300px',
            }}>
                <Box>
                    <Typography variant="h5">Darvester (API)<StatusIndicator status={apiStatus.status} style={{
                        position: 'relative',
                        top: 0,
                        left: 0,
                        transform: 'none',
                        border: 'none',
                        margin: '4px',
                        marginRight: '12px'
                        }} /></Typography>
                    <Typography variant="body1"><i>Status:</i> {apiStatus.status}</Typography>
                    <Box component="div" sx={{ display: 'inline', padding: '12px', textAlign: 'center' }}>
                        <Button variant="outlined" sx={{ margin: '8px 12px -4px'}}>Start</Button>
                        <Button variant="outlined" sx={{ margin: '8px 12px -4px'}}>Stop</Button>
                    </Box>
                </Box>
            </Box></Fade></Grow>
        </Box>
    )
}
