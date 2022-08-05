import React from 'react';
import {
    Box,
    Typography,
    Snackbar
} from '@mui/material';
import ImageWithFallback from '../components/Image';

import ContentCopyIcon from '@mui/icons-material/ContentCopy';
import LinearProgress from '@mui/material/LinearProgress';

import { useSearchParams, Link } from 'react-router-dom';
import { theme, getSmallerIcon } from '../common';

import { HOST, PORT } from '../config';

var JSONBig = require('json-bigint');

export default function Guild() {
    const [searchParams, setSearchParams] = useSearchParams();
    const [guild, setGuild] = React.useState({});
    const [guildMembers, setGuildMembers] = React.useState([]);
    const [open, setOpen] = React.useState(false);
    const [copied, setCopied] = React.useState(false);
    const [snackbarMessage, setSnackbarMessage] = React.useState('');   

    React.useEffect(() => {
        let _promises = [];
        _promises.push(fetch(`http://${HOST}:${PORT}/guilds/${searchParams.get('id')}`).then((resp) => resp.text()).then((data) => {
            data = JSONBig.parse(data);
            data['first_seen_string'] = new Date(data.first_seen * 1000).toLocaleDateString("en-US", {
                month: "2-digit",
                day: "2-digit",
                year: "numeric",
                hour: "2-digit",
                minute: "2-digit"
            });
            setGuild(data);
        }));
        _promises.push(fetch(`http://${HOST}:${PORT}/guilds/${searchParams.get('id')}/members`).then((resp) => resp.text()).then(
            (data) => {
                data = JSONBig.parse(data);
                setGuildMembers(data['members']);
            }
        ));
        Promise.all(_promises)
            .then(() => {
                setOpen(true);
            });
        return () => {
            setOpen(false);
        }
    }, [searchParams]);

    const switchPremiumTier = (tier) => {
        switch(tier) {
            case 0:
                return (
                    <Typography variant='body1' component='span'>
                        Server has not reached a boost level
                    </Typography>
                );
            case 1:
                return (
                    <Typography variant='body1' component='span'>
                        Level 1 Unlocked
                        <li>+50 server emoji slots for a total of 100</li>
                        <li>+10 custom sticker slots for a total of 15</li>
                        <li>128 kbps audio quality</li>
                        <li>Animated server icon</li>
                        <li>Custom server invite background</li>
                        <li>Sream to your friends in high quality</li>
                    </Typography>
                );
            case 2:
                return (
                    <Typography variant='body1' component='span'>
                        Level 2 Unlocked
                        <li>+50 server emoji slots for a total of 150</li>
                        <li>+15 custom sticker slots for a total of 30</li>
                        <li>256 kbps audio quality</li>
                        <li>Server banner</li>
                        <li>50 MB upload limit for all members</li>
                        <li>1080p 60fps Go Live streams</li>
                        <li>Create private threads</li>
                        <li>Custom Role Icons</li>
                    </Typography>
                );
            case 3:
                return (
                    <Typography variant='body1' component='span'>
                        Level 3 Unlocked
                        <li>+100 server emoji slots for a total of 250</li>
                        <li>+30 custom sticker slots for a total of 60</li>
                        <li>384 kbps audio quality</li>
                        <li>Custom Invite Link for the server</li>
                        <li>100MB upload limit for all members</li>
                        <li>Animated Server Banner</li>
                    </Typography>
                );
            default:
                return "Boost status is unknown";
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
                <ImageWithFallback fallback="transparent.png" src={guild.splash_url} id="guild_splash" className={open ? "home_header" : "home_header hide"} alt="" />
            </Box>
            <Box sx={{
                    width: { xs: '100%', md: '80%' },
                    margin: 'auto',
                    marginBottom: '1rem',
                    padding: theme.spacing(2),
                    borderRadius: "4px",
                    wordBreak: 'break-all',
                    maxWidth: '100%'
                }}>
                <ImageWithFallback fallback="default_avatar.png" src={getSmallerIcon(guild['icon'], 128)} alt={guild.name} width={128} height={128} style={{
                    borderRadius: "50%",
                    padding: theme.spacing(1, 1, 1, 1),
                }} />
                <Typography variant="h1" component="span" align="left" className={open ? 'home_header' : 'home_header hide'} sx={{
                    fontWeight: 'bold',
                    fontSize: { xs: '3rem', md: '7rem' },
                    display: 'inline-block',
                    transform: 'translateY(-1.6rem)',
                    paddingLeft: { xs: '8px', md: '24px'},
                    paddingTop: { xs: '14px', md: '0' }
                }}>
                    {guild['name']}
                </Typography>
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
                    Guild
                </Typography>
                <Typography variant="h6" component="span" sx={{
                    fontWeight: 'light',
                    opacity: '50%',
                    marginLeft: '12px',
                }}>
                    {} with {guild['member_count']} members, first seen on {guild.first_seen_string}
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
                            Description
                        </Typography>
                        <Typography variant="body1" component="span" className='guild_info_body'>
                            {guild['description']}
                        </Typography>
                    </Box>

                    <Box sx={{
                        float: { xs: 'left', md: 'right' },
                        width: { xs: '100%', md: '45%' },
                        display: 'block'
                    }}>
                        <Typography variant="h4" className='guild_info_header'>
                            Owner
                        </Typography>
                        <Typography variant="body1" component="div" className='guild_info_body' sx={{
                            width: { xs: '100%', md: '45%' },
                        }}>
                            <Link to={`/user?id=${guild.owner?.id?.toString() ?? ''}`} onClick={() => {window.scrollTo(0, 0)}}>
                                {guild.owner?.name ?? "None"}
                            </Link>
                            <ContentCopyIcon sx={{
                                fontSize: '20px',
                                cursor: 'pointer',
                                paddingLeft: '6px',
                                zIndex: '99',
                                position: 'absolute'
                            }} onClick={() => {
                                navigator.clipboard.writeText(`${guild.owner?.id?.toString() ?? ''}`);
                                setSnackbarMessage("ID");
                                setCopied(true);
                            }} />
                        </Typography>
                    </Box>
                </Box>

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
                        <Typography variant="h4" className="guild_info_header">Features</Typography>
                        <Typography variant="body1" component="span" className='guild_info_body'>
                            {guild.features?.length ? guild.features?.map((row, index) => {
                                return (
                                    <li>{row}</li>
                                );
                            }) : "None"}
                        </Typography>
                    </Box>
                    <Box sx={{
                        float: { xs: 'left', md: 'right' },
                        width: { xs: '100%', md: '45%' },
                        display: 'block'
                    }}>
                        <Typography variant="h4" className="guild_info_header">Nitro Tier</Typography>
                        <Typography variant="body1" component="span" className='guild_info_body'>
                            {switchPremiumTier(guild.premium_tier)}
                        </Typography>
                    </Box>
                </Box>

                <Typography variant="h4" className='guild_info_header'>
                    Members
                </Typography>
                <Typography variant="body1" component="div" className='guild_info_body guild_info_members' sx={{
                    maxHeight: '800px',
                    overflowY: 'auto',
                }}>
                    {guildMembers
                        .map((row, index) => {
                        return (
                            <Box className="guild_info_member" sx={{
                                padding: '0.25rem',
                                width: '250px'
                            }}>
                                <Link to={`/user?id=${row['id']}`} onClick={() => {window.scrollTo(0, 0)}}>
                                    <Box sx={{
                                        width: 'min-content',
                                        margin: 'auto'
                                    }}>
                                        <ImageWithFallback src={getSmallerIcon(row['avatar_url'], 128)} fallback="default_avatar.png" alt={row['name']} width={128} height={128} loading="lazy" style={{
                                            borderRadius: '50%'
                                        }}/>
                                    </Box>
                                </Link>
                                <Box sx={{
                                    margin: 'auto',
                                    // width: 'max-content'
                                    maxWidth: '250px',
                                    padding: '4px',
                                }}>
                                    <Link to={`/user?id=${row['id']}`} onClick={() => {window.scrollTo(0, 0)}}>
                                    <Typography variant="subtitle2" sx={{
                                            fontWeight: 'bold',
                                            fontSize: {xs: "14px", md: "18px"},
                                            wordWrap: 'break-word',
                                            wordBreak: 'break-all',
                                        }}
                                        component="span">
                                        {row['name']}
                                    </Typography>
                                    <Typography variant="subtitle2" component="span" sx={{
                                        fontSize: '14px',
                                    }}>
                                        #{row['discriminator']}
                                    </Typography>
                                    </Link>
                                    <ContentCopyIcon sx={{
                                        fontSize: '20px',
                                        cursor: 'pointer',
                                        paddingLeft: '6px',
                                        zIndex: '99'
                                    }} onClick={() => {
                                        navigator.clipboard.writeText(`${row['id']}`);
                                        setSnackbarMessage("ID");
                                        setCopied(true);
                                    }} />
                                </Box>
                            </Box>
                        );
                    })}
                </Typography>
            </Box>
            <Snackbar 
                open={copied}
                onClose={() => {setCopied(false)}}
                message={`Copied ${snackbarMessage} to clipboard`}
                autoHideDuration={2000}
            />
        </Box>
    );
}