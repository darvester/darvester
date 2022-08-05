import { createTheme } from '@mui/material/styles';

import FacebookIcon from '@mui/icons-material/Facebook';
import RedditIcon from '@mui/icons-material/Reddit';
import MusicNoteIcon from '@mui/icons-material/MusicNote';
import SportsEsportsIcon from '@mui/icons-material/SportsEsports';
import TwitterIcon from '@mui/icons-material/Twitter';
import YouTubeIcon from '@mui/icons-material/YouTube';

// Sorting 
export function descComp(a, b, orderBy) {
    if (b[orderBy] < a[orderBy]) {
      return -1;
    }
    if (b[orderBy] > a[orderBy]) {
      return 1;
    }
    return 0;
}

export const getComparator = (order, orderBy) => {
    return order === 'desc'
        ? (a, b) => descComp(a, b, orderBy)
        : (a, b) => -descComp(a, b, orderBy);
}

// Utilities
export function getSmallerIcon(url, size) {
    try {
        url = new URL(url);
        url.searchParams.set('size', size ? size.toString() : '64');
        url.search = url.searchParams.toString();
        return url.toString();
    } catch (e) {
        console.log(e);
        return "#";
    }
}

export function debounce(func, delay) {
    let debounceTimer;
    return function() {
        const context = this;
        const args = arguments;
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => func.apply(context, args), delay);
    }
}

export function requestSearch(input) {
    console.log(input);
}

export const theme = createTheme({
    palette: {
      mode: 'dark',
    },
});

export function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

// - parse connected_acounts

export function parseGithub(id) {
    return new Promise(() => {
        fetch(`https://api.github.com/user/${id}`)
            .then((resp) => resp.json())
            .then((resp) => {
                return resp.html_url?.toString()
            })
        }
    );
}

export function parseConnectedAccount({id, type, name}) {
    switch(type) {
        case "facebook":
            return [FacebookIcon, "#"]; // unfortunately, Facebook does not allow `https://facebook.com/${id}` anymore
        // case "github":
            // return [GitHubIcon, await parseGithub(id) ?? `https://github.com/${name}`];
        case "reddit":
            return [RedditIcon, `https://reddit.com/u/${name}`];
        case "spotify":
            return [MusicNoteIcon, `https://open.spotify.com/user/${id}`];
        case "steam":
            return [SportsEsportsIcon, `https://steamcommunity.com/id/${id}`];
        case "twitch":
            return [SportsEsportsIcon, `https://twitch.tv/${name}`];
        case "xbox":
            return [SportsEsportsIcon, "#"];
        case "battlenet":
            return [SportsEsportsIcon, "#"];
        case "playstation":
            return [SportsEsportsIcon, "#"];
        case "twitter":
            return [TwitterIcon, `https://twitter.com/${name}`];
        case "youtube":
            return [YouTubeIcon, `https://youtube.com/channel/${id}`];
        default:
            return [null, name];
    }
}

export function secondsToHms(d) {
    d = Number(d);
    var h = Math.floor(d / 3600);
    var m = Math.floor(d % 3600 / 60);
    var s = Math.floor(d % 3600 % 60);

    var hDisplay = h > 0 ? h + (h === 1 ? " hour, " : " hours, ") : "";
    var mDisplay = m > 0 ? m + (m === 1 ? " minute, " : " minutes, ") : "";
    var sDisplay = s > 0 ? s + (s === 1 ? " second" : " seconds") : "";
    return hDisplay + mDisplay + sDisplay; 
}
