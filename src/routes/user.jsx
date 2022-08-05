import React from 'react';
import {
    Box,
    Typography,
    Snackbar
} from '@mui/material';
import ImageWithFallback from '../components/Image';
import StatusIndicator from '../components/Status';
import GitHubIcon from '@mui/icons-material/GitHub';

import ContentCopyIcon from '@mui/icons-material/ContentCopy';
import LinearProgress from '@mui/material/LinearProgress';
import Tooltip from '@mui/material/Tooltip';

import { useSearchParams, Link } from 'react-router-dom';
import { theme, getSmallerIcon, parseConnectedAccount, capitalizeFirstLetter, secondsToHms } from '../common';

import { HOST, PORT } from '../config';

var JSONBig = require('json-bigint');

export default function User() {
    const [searchParams, setSearchParams] = useSearchParams();
    const [user, setUser] = React.useState({});
    
    const [userGuilds, setUserGuilds] = React.useState([]);
    const [userConnections, setUserConnections]  = React.useState([]);
    const [open, setOpen] = React.useState(false);
    const [copied, setCopied] = React.useState(false);
    const [snackbarMessage, setSnackbarMessage] = React.useState('');

    React.useEffect(() => {
        let _promises = [];
        let _tmp_user_guilds = [];
        let _tmp_user_connections = [];
        fetch(`http://${HOST}:${PORT}/users/${searchParams.get('id')}`).then((resp) => resp.text())
            .then((data) => {
                data = JSONBig.parse(data);
                data['first_seen_string'] = new Date(data.first_seen * 1000).toLocaleDateString("en-US", {
                    month: "2-digit",
                    day: "2-digit",
                    year: "numeric",
                    hour: "2-digit",
                    minute: "2-digit"
                });
                data['premium_since_string'] = data?.premium_since ? new Date(data?.premium_since * 1000).toLocaleDateString("en-US", {
                    month: "2-digit",
                    day: "2-digit",
                    year: "numeric",
                    hour: "2-digit",
                    minute: "2-digit"
                }) : "";
                data['created_at_string'] = new Date(data.created_at * 1000).toLocaleDateString("en-US", {
                    month: "2-digit",
                    day: "2-digit",
                    year: "numeric",
                    hour: "2-digit",
                    minute: "2-digit"
                });
                data['id'] = data['id'].toString();
                setUser(data);
                data.mutual_guilds?.guilds?.forEach(guildID => {
                    _promises.push(
                        fetch(`http://${HOST}:${PORT}/guilds/${guildID}`)
                            .then((data) => data.text())
                            .then((data) => {
                                data = JSONBig.parse(data);
                                _tmp_user_guilds.push(data);
                            })
                    )
                });
                data.connected_accounts?.forEach(account => {
                    if (account?.type === "github") {
                        _promises.push(fetch(`https://api.github.com/user/${account.id}`)
                        .then((resp) => resp.json())
                        .then((resp) => {
                            _tmp_user_connections.push([GitHubIcon, resp.html_url?.toString(), account])
                        }, (error) => {
                            _tmp_user_connections.push([GitHubIcon, `https://github.com/${account.name}`, account])
                            console.log(error)
                        }))
                    } else {
                        _tmp_user_connections.push([...parseConnectedAccount(account), account])
                    }
                });
                Promise.all(_promises)
                .then(() => {
                    setUserGuilds(_tmp_user_guilds);
                    setUserConnections(_tmp_user_connections);
                    setOpen(true);
                });
            }
        );
        return () => {
            setOpen(false);
        }
    }, [searchParams]);

    const getNitroDetails = () => {
        switch(user['premium']) {
            case "True":
                return (
                    <Typography>
                        Subscribed since {user.premium_since_string}
                    </Typography>
                );
            case "False":
                return (
                    <Typography>
                        Not subscribed
                    </Typography>
                );
            default:
                return (
                    <Typography>
                        Nitro status unknown
                    </Typography>
                );
        }
    }

    return (
        <Box>
            <LinearProgress sx={{
                display: open ? "none" : "block"
            }}/>
            <Box sx={{
                position: 'absolute',
                top: '76px',
                zIndex: '-5',
                opacity: '0.5',
                width: '100%',
                overflow: 'hidden'
            }}>
                {/* <ImageWithFallback fallback="transparent.png" src={user.banner} /> /* senile man forgot to add banner to the schema */}
            </Box>
            <Box sx={{
                width: { xs: '100%', md: '80%' },
                margin: 'auto',
                marginBottom: '1rem',
                padding: theme.spacing(2),
                borderRadius: '4px',
                wordBreak: 'break-all',
                maxWidth: '100%',
                display: { xs: 'block', md: 'flex'}
            }}>
                <Box component="div" sx={{
                    position: 'relative',
                    width: '128px',
                    height: '128px',
                }}>
                    <ImageWithFallback fallback="default_avatar.png" src={getSmallerIcon(user['avatar_url'], 128)} alt={user.name} width={128} height={128} style={{
                        borderRadius: "50%",
                        padding: theme.spacing(1),
                    }} />
                    <StatusIndicator status={user?.status} />
                </Box>
                <Box sx={{
                    display: 'flex'
                }}>
                    <Typography variant="h1" component="span" align="left" className={open ? 'home_header' : 'home_header hide'} sx={{
                        fontWeight: 'bold',
                        fontSize: { xs: '3rem', md: '7rem' },
                        display: 'inline-block',
                        paddingLeft: { xs: '8px', md: '24px'},
                        paddingTop: { xs: '14px', md: '0' },
                        zIndex: '4',
                        cursor: 'pointer',
                    }} onClick={() => {
                        navigator.clipboard.writeText(`${user['name']}#${user['discriminator']}`);
                        setSnackbarMessage(`${user.name}#${user.discriminator}`);
                        setCopied(true);
                    }}>
                        {user['name']}
                    </Typography>
                    <Typography variant="h4" component="span" align="left" className={open ? 'home_header' : 'home_header hide'} sx={{
                        fontWeight: 'light',
                        fontSize: { xs: '2rem', md: '5rem' },
                        transform: 'translateY(1.6rem)',
                        paddingLeft: { xs: '8px', md: '24px'},
                        paddingTop: { xs: '14px', md: '0' },
                        cursor: 'pointer',
                        width: 'max-content',
                        flex: 'max-content',
                        whiteSpace: 'nowrap'
                    }} onClick={() => {
                        navigator.clipboard.writeText(`${user['id']}#${user['discriminator']}`);
                        setSnackbarMessage(`${user.name}#${user.discriminator}`);
                        setCopied(true);
                    }}  >
                        #{user['discriminator']}
                    </Typography>
                </Box>
            </Box>

            <Box className={open ? 'home_header' : 'home_header hide'} sx={{
                backgroundColor: "#373737",
                width: { xs: '100%', md: '80%' },
                margin: 'auto',
                marginBottom: '1rem',
                padding: theme.spacing(2),
                borderRadius: "4px",
            }}>
                <Typography variant="h2" component="span" sx={{
                    fontWeight: 'lighter',
                    opacity: '30%'
                }}>
                    User
                </Typography>
                <Typography variant="h6" component="span" sx={{
                    fontWeight: 'light',
                    opacity: '50%',
                    marginLeft: '12px',
                }}>
                    {} first seen on {user.first_seen_string}, created at {user.created_at_string}
                </Typography>

                <Box sx={{
                    marginBottom: '24px',
                    display: { xs: 'block', md: 'table' },
                    width: '100%'
                }}>
                    <Box sx={{
                        float: 'left',
                        width: { xs: '100%', md: '45%' },
                        display: 'block'
                    }}>
                        <Typography variant="h4" className='guild_info_header' sx={{
                            maxWidth: '45%'
                        }}>
                            Bio
                        </Typography>
                        <Typography variant="body1" component="span" className='guild_info_body'>
                            {user.bio?.toString()}
                        </Typography>
                    </Box>
                    <Box sx={{
                        float: { xs: 'left', md: 'right'},
                        width: { xs: '100%', md: '50%' },
                        display: 'block'
                    }}>
                        <Typography variant="h4" className='guild_info_header'>
                            Nitro
                        </Typography>
                        <Typography variant="body1" component="div" className='guild_info_body' sx={{
                            width: { xs: '100%', md: '45%' }
                        }}>
                            {getNitroDetails()}
                        </Typography>
                    </Box>
                </Box>

                <Typography variant="h4" className='guild_info_header'>
                    Connections
                </Typography>
                <Typography variant="body1" component="div" className='guild_info_body guild_info_members' sx={{
                    maxHeight: '800px',
                    overflowY: 'auto',
                }}>
                    {userConnections.map((account, index) => {
                        const Icon = account[0] ?? Box;
                        return (
                            <Box className="guild_info_member" sx={{
                                padding: '0.25rem',
                                width: '250px'
                            }}>
                                <a href={account[1]} target={account[1] !== "#" ? "_blank" : "_self"} style={account[1] === "#" ? {pointerEvents: 'none'} : {}} rel="noreferrer">
                                    <Box sx={{
                                        width: 'min-content',
                                        margin: 'auto'
                                    }}>
                                        <Icon style={{ fontSize: '64px' }} />
                                    </Box>
                                </a>
                                <Box sx={{
                                    margin: 'auto',
                                    maxWidth: '250px',
                                    padding: '4px'
                                }}>
                                    <a href={account[1]} target={account[1] !== "#" ? "_blank" : "_self"} style={account[1] === "#" ? {pointerEvents: 'none'} : {}} rel="noreferrer">
                                        <Typography variant="subtitle2" sx={{
                                            fontWeight: 'lighter',
                                            fontSize: { xs: '18px', md: '22px' },
                                        }}>
                                            {capitalizeFirstLetter(account[2]?.type)}
                                        </Typography>
                                        <Typography variant="subtitle2" sx={{
                                                fontWeight: 'bold',
                                                fontSize: {xs: "14px", md: "18px"},
                                                wordWrap: 'break-word',
                                                wordBreak: 'break-word',
                                            }}
                                            component="span">
                                            {account[2]?.name}
                                        </Typography>
                                    </a>
                                    <ContentCopyIcon sx={{
                                        fontSize: '20px',
                                        cursor: 'pointer',
                                        paddingLeft: '6px',
                                        zIndex: '99'
                                    }} onClick={() => {
                                        navigator.clipboard.writeText(account[1] !== "#" ? account[1] : account[2]?.id);
                                        setSnackbarMessage(account[1] !== "#" ? "account URL" : "account ID");
                                        setCopied(true);
                                    }} />
                                </Box>
                            </Box>
                        );
                    })}
                </Typography>
                <Typography variant="h4" className='guild_info_header'>
                    Guilds
                </Typography>
                <Typography variant="body1" component="div" className='guild_info_body guild_info_members' sx={{
                    maxHeight: '800px',
                    overflowY: 'auto',
                }}>
                    {userGuilds.map((guild, index) => {
                        return (
                            <Box key={guild?.id} className="guild_info_member" sx={{
                                padding: '0.25rem',
                                width: '250px'
                            }}>
                                <Link to={`/guild?id=${guild.id.toString()}`} onClick={() => {window.scrollTo(0, 0)}}>
                                    <Box sx={{
                                        width: 'min-content',
                                        margin: 'auto'
                                    }}>
                                        <ImageWithFallback src={getSmallerIcon(guild['icon'], 128)} fallback="default_avatar.png" alt={guild['name']} width={128} height={128} loading="lazy" style={{
                                            borderRadius: '50%'
                                        }} className="guild_icon" />
                                    </Box>
                                </Link>
                                <Box sx={{
                                    margin: 'auto',
                                    maxWidth: '250px',
                                    padding: '4px'
                                }}>
                                    <Link to={`/guild?id=${guild.id.toString()}`} onClick={() => {window.scrollTo(0, 0)}}>
                                        <Typography variant="subtitle2" sx={{
                                                fontWeight: 'bold',
                                                fontSize: {xs: "14px", md: "18px"},
                                                wordWrap: 'break-word',
                                                wordBreak: 'break-all',
                                            }}
                                            component="span">
                                            {guild['name']}
                                        </Typography>
                                    </Link>
                                    <ContentCopyIcon sx={{
                                        fontSize: '20px',
                                        cursor: 'pointer',
                                        paddingLeft: '6px',
                                        zIndex: '99'
                                    }} onClick={() => {
                                        navigator.clipboard.writeText(`${guild['id']}`);
                                        setSnackbarMessage("ID for " + guild.name);
                                        setCopied(true);
                                    }} />
                                </Box>
                            </Box>
                        );
                    })}
                </Typography>
                <Box sx={{
                    marginBottom: '24px',
                    display: { xs: 'block', md: 'table' },
                    width: '100%',
                    transform: { xs: 'translateY(40px)', md: 'none'}
                }}>
                    <Box sx={{
                        float: 'left',
                        width: { xs: '100%', md: '45%' },
                        display: 'block',
                    }}>
                        <Typography variant="h4" className='guild_info_header' sx={{
                            maxWidth: '45%'
                        }}>
                            Flags
                        </Typography>
                        <Typography variant="body1" component="span" className='guild_info_body'>
                            {user?.public_flags?.length ? user?.public_flags?.map((flag, index) => {
                                return (<li>{flag}</li>);
                            }) : "None"}
                        </Typography>
                    </Box>
                    <Box sx={{
                        float: { xs: 'left', md: 'right'},
                        width: { xs: '100%', md: '50%' },
                        display: 'block'
                    }}>
                        <Typography variant="h4" className='guild_info_header'>
                            Last Activities
                        </Typography>
                        <Typography variant="body1" component="div" className='guild_info_body' sx={{
                            width: { xs: '100%', md: '45%' }
                        }}>
                            {user?.activities?.length ? user?.activities?.map((activity, index) => {
                                const start = new Date(Math.floor(activity.start) * 1000);
                                const type = () => {
                                    if (activity.type === "custom") {
                                        if (activity.emoji) {
                                            return (
                                                <>
                                                    Playing <Tooltip title={`<:${activity.emoji?.name}:${activity.emoji?.id}>`} placement="top" arrow>
                                                        <ImageWithFallback src={getSmallerIcon(activity.emoji?.url, 16)} fallback="transparent.png" width={16} height={16} alt={activity.emoji?.name} />
                                                    </Tooltip>
                                                </>
                                            )
                                        }
                                    } else {
                                        switch(activity.type) {
                                            case "listening":
                                                return "Listening to";
                                            default:
                                                return capitalizeFirstLetter(activity.type);
                                        }
                                    }
                                }
                                return (
                                    <Box
                                        component={activity.url ? "a" : "div"}
                                        href={activity.url}
                                        target="_blank"
                                    >
                                        <Box sx={{
                                            backgroundColor: '#222222',
                                            padding: theme.spacing(1),
                                            borderRadius: '4px',
                                            margin: theme.spacing(1)
                                        }}
                                        component="div"
                                        >
                                            <Typography variant="h6" sx={{
                                                fontWeight: 'light'
                                            }}
                                            component="span">
                                                {type()}
                                            </Typography>
                                            <Typography variant="body1" sx={{
                                                fontWeight: 'bold'
                                            }}
                                            component="span">
                                                {} {capitalizeFirstLetter(activity.name)}
                                            </Typography>
                                            <Typography variant="body1" sx={{
                                                fontSize: '16px'
                                            }}
                                            component="div">
                                                {activity.details !== "None" ? activity.details : ""}
                                            </Typography>
                                            <Typography variant="body1" sx={{
                                                fontSize: '12px',
                                                opacity: '0.5'
                                            }}
                                            component="div">
                                                {activity.end ? `Duration: ${secondsToHms(Math.floor(activity.end) - Math.floor(activity.start))}` : (activity.start ? `Started on ${start.toLocaleDateString("en-US", {
                                                    month: "2-digit",
                                                    day: "2-digit",
                                                    year: "numeric",
                                                    hour: "2-digit",
                                                    minute: "2-digit"
                                                })}` : "")}
                                            </Typography>
                                        </Box>
                                    </Box>
                                );
                            }) : "None"}
                        </Typography>
                    </Box>
                </Box>
            </Box>
            <Snackbar 
                open={copied}
                onClose={() => {setCopied(false)}}
                message={`Copied ${snackbarMessage} to clipboard`}
                autoHideDuration={2000}
            />
        </Box>
    )
}
