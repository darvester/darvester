// Core
import React from 'react';
import ReactDOM from 'react-dom/client';
import { HashRouter, Routes, Route } from "react-router-dom";
import { channels } from './constants';

// Components
import { SearchAppBar } from './components/Search';
import {
  Box,
  Typography
} from '@mui/material';

// Styles
import './index.css';
import CssBaseline from '@mui/material/CssBaseline';
import { ThemeProvider } from '@mui/material/styles';
import { theme } from './common';

// Routes
import { default as Guilds } from './routes/guilds';
import Guild from './routes/guild';
import Users from './routes/users';
import User from './routes/user';

const root = ReactDOM.createRoot(document.getElementById('root'));
const { ipcRenderer } = window.require('electron');

const DetermineFirstRun = function() {
  const getFirstRun = () => {
    ipcRenderer.send(channels.FIRST_RUN, { method: 'get' });
  }
}

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      open: false,
    }
  }

  componentDidMount() {
    this.setState({ open: true });
  }
  
  componentWillUnmount() {
    this.setState({ open: false });
  }

  render() {
    const classes = this.state.open ? 'home_header' : 'home_header hide';
    return (
      <Box>
        <Typography variant="h1" component="h1" align="center" className={classes}>
          Darvester
        </Typography>
        <Box sx={{
          backgroundColor: "#444444",
          width: { xs: '100%', md: '80%' },
          margin: 'auto',
          marginBottom: '1rem',
          padding: theme.spacing(2),
          borderRadius: "4px",
        }}>
          To get started, open the drawer on the left or begin a search.
        </Box>
        <Box sx={{
          backgroundColor: "#444444",
          width: { xs: '100%', md: '80%' },
          margin: 'auto',
          marginBottom: '1rem',
          padding: theme.spacing(2),
          borderRadius: "4px",
        }}>
          Stuff and things
        </Box>
      </Box>
    );
  }
}

root.render(
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <HashRouter>
        <Routes>
          <Route path="/" element={<DetermineFirstRun />}>
            <Route path="/" element={<App />} />
            <Route path="guilds" element={<Guilds />} />
            <Route path="users" element={<Users />} />
            <Route path="info" element={<></>} />
            <Route path="guild" element={<Guild />} />
            <Route path="user" element={<User />} />
          </Route>
        </Routes>
      </HashRouter>
    </ThemeProvider>
);
