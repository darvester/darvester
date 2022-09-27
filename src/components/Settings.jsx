import React from 'react';

import {
    Box,
    Typography,
    Fade,
    Grow,
    Switch,
    TextField,
    Autocomplete,
    Chip,
    Tooltip,
    Snackbar
} from '@mui/material';

import { PORT } from '../config';

var JSONBig = require('json-bigint');

function IgnoreGuilds(props) {
    const [guilds, setGuilds] = React.useState([]);
    const [isLoaded, setIsLoaded] = React.useState(false);

    React.useEffect(() => {
        fetch(`http://localhost:${PORT}/guilds`)
            .then(res => res.text())
            .then(
                (result) => {
                    result = JSONBig.parse(result)
                    setGuilds([...result.guilds.map((guild) => {return {
                        id: guild.id,
                        name: guild.name
                    }})]);
                    setIsLoaded(true);
                },
                (error) => {
                    setIsLoaded(true);
                    setGuilds([{
                        id: null,
                        name: "Error: " + error.message
                    }]);
                }
            )
    }, []);

    return (
        <Autocomplete
            multiple
            id="tags-filled"
            options={guilds}
            getOptionLabel={(guild) => guild.name}
            freeSolo
            onChange={(event, value) => {
                console.log(value);
            }}
            renderTags={(value, getTagProps) =>
            value.map((option, index) => (
                <Chip variant="outlined" label={option.name ?? option} {...getTagProps({ index })} />
            ))
            }
            renderInput={(params) => (
                <TextField
                    {...params}
                    variant="outlined"
                    label="Ignored Guilds"
                    placeholder="Guilds"
                />
            )}
            {...props}
      />
    )
}

export default function Settings() {
    const [isMounted, setIsMounted] = React.useState(false);
    const [config, setConfig] = React.useState({});

    const [ignoredGuilds, setIgnoredGuilds] = React.useState([]);
    const [swapIgnoreGuilds, setSwapIgnoreGuilds] = React.useState(false);
    const [enablePresence, setEnablePresence] = React.useState(false);

    const [openSnackbar, setOpenSnackbar] = React.useState(false);
    const [snackbarMessage, setSnackbarMessage] = React.useState("");

    React.useEffect(() => {
        if (snackbarMessage !== "") setOpenSnackbar(true);
    }, [snackbarMessage])

    React.useEffect(() => {
        setIsMounted(true);
        window.electronAPI.getConfig().then((res) => setConfig(res));
        // setIgnoredGuilds(config?.core_ignored_guilds);
        // setSwapIgnoreGuilds(config?.core_swap_ignore);
        // setEnablePresence(config?.core_enable_presence);
        return () => {
            setIsMounted(false);
        }
    }, []);

    return (
        <Box>
            <Grow in={isMounted} timeout={1000} style={{ transformOrigin: '0 0 0' }}><Fade in={isMounted} timeout={600}><Typography variant="h2" align="center" sx={{ padding: '20px', fontWeight: 'light' }}>Settings</Typography></Fade></Grow>
            <Typography variant="h4" sx={{ padding: '20px', fontWeight: 'light' }}>Core</Typography>
            <Box sx={{
                margin: '10px auto',
                padding: '20px',
                backgroundColor: '#444444',
                borderRadius: '6px',
                width: '90%'
            }}>
                <Typography component="p" variant="h5" sx={{ padding: '6px 0' }}>Token</Typography>
                <i><sup style={{ margin: "0 16px" }}>Note: The token is not readable by the user once saved</sup></i><br />
                <TextField label="Token" type="password" value={"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"} sx={{ width: "300px", margin: "6px 14px" }}/>

                <Tooltip
                    title="List of guilds to ignore. If guild isn't in database, add it by inputting the guild's ID"
                    placement="top-start"
                    followCursor={true}
                    enterDelay={500}
                >
                    <Typography component="p" variant="h5" sx={{ padding: '6px 0' }}>Ignore Guilds</Typography>
                </Tooltip>
                <IgnoreGuilds style={{ marginLeft: "16px", fontWeight: "lighter" }} />
                <Tooltip
                    title="Swap from blacklist (default) to whitelist (only scan specified guilds)"
                    placement="top-start"
                    followCursor={true}
                    enterDelay={500}
                >
                    <span style={{ marginLeft: "16px", fontWeight: "lighter" }}>{swapIgnoreGuilds ? "Guilds whitelisted" : "Guilds blacklisted"}
                        <Switch checked={swapIgnoreGuilds} onChange={(e) => {
                            window.electronAPI.writeConfigKey("core_swap_ignore", e.target.checked).then((res) => {
                                if (res) {
                                    setSnackbarMessage("Swap ignore guilds updated")
                                    setTimeout(() => setSwapIgnoreGuilds(e.target.checked), 100);
                                } else {
                                    setSnackbarMessage(`Swap ignore guilds ${e.target.checked} failed to update`)
                                }
                            });
                        }}/>
                    </span>
                </Tooltip>

                <Tooltip
                    title="Enable Discord Rich Presence for bot and client. This will show your Darvester activity on your Discord status (for both your personal and harvesting accounts)"
                    placement="top-start"
                    followCursor={true}
                    enterDelay={500}
                >
                    <Typography component="p" variant="h5" sx={{ padding: '6px 0' }}>Enable Rich Presence</Typography>
                </Tooltip>
                <Tooltip
                    title="Enable Discord Rich Presence for bot and client. This will show your Darvester activity on your Discord status (for both your personal and harvesting accounts)"
                    placement="top-start"
                    followCursor={true}
                    enterDelay={500}
                ><Switch checked={enablePresence || false} onChange={(e) => {
                    window.electronAPI.writeConfigKey("core_enable_presence", e.target.checked).then((res) => {
                        if (res) {
                            setSnackbarMessage("Rich Presence updated");
                            setTimeout(() => setEnablePresence(e.target.checked), 100);
                        } else {
                            setSnackbarMessage(`Rich Presence ${e.target.checked} failed to update`)
                        }
                    })
                }} /></Tooltip>
                
                <Tooltip
                    title="The path and name of the database file you want to dump harvested info to"
                    placement="top-start"
                    followCursor={true}
                    enterDelay={500}
                >
                    <Typography component="p" variant="h5" sx={{ padding: '6px 0' }}>Database Location</Typography>
                </Tooltip>

                <Tooltip
                    title="Suppress some sensitive information going to the logs and rich presence. Does not affect info being harvested"
                    placement="top-start"
                    followCursor={true}
                    enterDelay={500}
                >
                    <Typography component="p" variant="h5" sx={{ padding: '6px 0' }}>Quiet Mode</Typography>
                </Tooltip>
                <Switch />
            </Box>
            <Snackbar 
                open={openSnackbar}
                autoHideDuration={4000}
                onClose={(event, reason) => {
                    if (reason === 'clickaway') return;
                    setOpenSnackbar(false);
                }}
                message={snackbarMessage}
            />
        </Box>
    );
}
