import * as React from 'react';
import { useEffect } from 'react';
import PropTypes from 'prop-types';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Modal from '@mui/material/Modal';
import Table from '@mui/material/Table';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import Snackbar from '@mui/material/Snackbar';
import TableHead from '@mui/material/TableHead';
import TableBody from '@mui/material/TableBody';
import TablePagination from '@mui/material/TablePagination';
import TableRow from '@mui/material/TableRow';
import TableCell from '@mui/material/TableCell';
import TableSortLabel from '@mui/material/TableSortLabel';
import { visuallyHidden } from '@mui/utils';
import { IconButton, Paper, TableContainer, Toolbar, Tooltip, Typography } from '@mui/material';
import { getComparator, getSmallerIcon } from '../common';
import CloseIcon from '@mui/icons-material/Close';
import { Link } from 'react-router-dom';

import { HOST, PORT } from '../config';

var JSONBig = require('json-bigint');

const columns = [
    { id: 'id', label: 'ID', minWidth: 70, align: 'right' },
    { id: 'name', label: 'Name', minWidth: 70, align: 'left' },
    { id: 'bio', label: 'Bio', minWidth: 70, align: 'left' },
    { id: 'avatar_url', label: 'Avatar', minWidth: 70, align: 'center' },
    { id: 'mutual_guilds', label: 'Guilds', minWidth: 70, align: 'left' },
    { id: 'premium', label: 'Has Nitro?', minWidth: 70, align: 'left' },
    { id: 'connected_accounts', label: 'Accounts', minWidth: 70, align: 'left' },
    { id: 'public_flags', label: 'Flags', minWidth: 70, align: 'left' },
    { id: 'created_at', label: 'Created', minWidth: 70, align: 'left' },
    { id: 'activities', label: 'Activities', minWidth: 70, align: 'left' },
    { id: 'status', label: 'Status', minWidth: 70, align: 'left' },
    { id: 'premium_since', label: 'Nitro Since', minWidth: 70, align: 'left' },
    { id: 'last_scanned', label: 'Last Scanned', minWidth: 70, align: 'left' },
    { id: 'first_seen', label: 'First Seen', minWidth: 70, align: 'left' },
]

function EnhancedTableHead(props) {
    const { order, orderBy, onRequestSort } = props;
    const createSortHandler = (property) => (event) => { onRequestSort(event, property); };

    return (
        <TableHead>
            <TableRow>
                {columns.map((column) => (
                    <TableCell
                        key={column.id}
                        align={column.align}
                        padding='normal'
                        sortDirection={orderBy === column.id ? order : false}
                        style={{ fontWeight: 'bold' }}
                    >
                        <TableSortLabel
                            active={orderBy === column.id}
                            direction={orderBy === column.id ? order : 'asc'}
                            onClick={createSortHandler(column.id)}
                        >
                            {column.label}
                            {orderBy === column.id ? (
                                <Box component='span' sx={visuallyHidden}>
                                    {order === 'desc' ? 'sorted descending' : 'sorted ascending'}
                                </Box>
                            ) : null}
                        </TableSortLabel>
                    </TableCell>
                ))}
            </TableRow>
        </TableHead>
    );
}

EnhancedTableHead.propTypes = {
    onRequestSort: PropTypes.func.isRequired,
    order: PropTypes.oneOf(['asc', 'desc']).isRequired,
    orderBy: PropTypes.string.isRequired,
}

const EnhancedTableToolbar = (props) => {
    return (
        <Toolbar
            sx={{
                pl: { sm: 2 },
                pr: { xs: 1, sm: 1 },
            }}
        >
            <Typography
                sx={{ flex: '1 1 100%', padding: '0.8rem', fontWeight: 'light' }}
                color="inherit"
                variant="h3"
                component="div"
                id="tableTitle"
            >
                Users
            </Typography>
        </Toolbar>
    )
}

export default function Users() {
    const [order, setOrder] = React.useState('asc');
    const [orderBy, setOrderBy] = React.useState('name');
    const [page, setPage] = React.useState(0);
    const [rowsPerPage, setRowsPerPage] = React.useState(25);

    // Modals
    const [guildsModalOpen, setGuildsModalOpen] = React.useState(false);
    const [guildsModalGuilds, setGuildsInModal] = React.useState([]);
    const [currentGuildsModal, setCurrentGuildsModal] = React.useState("");
    const handleGuildsOpen = (guilds, username) => {
        let _to_ret = [];
        let _promises = [];
        setSnackbarMessage(`Loading ${username}'s guilds...`);
        setSnackbarOpen(true);
        for (let i = 0; i < guilds.length; i++) {
            _promises.push(fetch(`http://${HOST}:${PORT}/guilds/` + guilds[i]).then(res => res.text()).then(data => {
                data = JSONBig.parse(data);
                _to_ret.push({
                    id: data.id.toString(),
                    name: data.name
                });
            }, (err) => {console.log("Could not fetch guild:", guilds[i], err.message)})
                .then(() => {
                    setGuildsInModal(_to_ret);
                    console.log(_to_ret, i);
                }));
        }
        Promise.all(_promises)
            .then(() => {
                console.log(_to_ret.length, guilds.length);
                console.log(_to_ret, "Done");
                setCurrentGuildsModal(username);
                setGuildsModalOpen(true)
            })
    };

    const handleGuildsClose = () => {
        setGuildsModalOpen(false)
        setGuildsInModal([]);
        setCurrentGuildsModal("");
    };

    const [error, setError] = React.useState(null);
    const [isLoaded, setIsLoaded] = React.useState(false);
    const [rows, setRows] = React.useState([]);
    const [copyRows, setCopyRows] = React.useState(rows);

    const [retry, setRetry] = React.useState(false);

    const [snackbarMessage, setSnackbarMessage] = React.useState("");
    const [snackbarOpen, setSnackbarOpen] = React.useState(false);
    const snackbarAction = (
        <React.Fragment>
            <IconButton
                size="small"
                aria-label="close"
                color="inherit"
                onClick={() => setSnackbarOpen(false)}
            >
                <CloseIcon fontSize="small" />
            </IconButton>
        </React.Fragment>
    )

    const handleSnackbarClose = (event, reason) => {
        if (reason === 'clickaway') {
            return;
        }
        setSnackbarOpen(false);
    }

    const handlerRequestSort = (event, property) => {
        const isAsc = orderBy === property && order === 'asc';
        setOrder(isAsc ? 'desc' : 'asc');
        setOrderBy(property);
        setSnackbarMessage(`Sorting ${property} by ${isAsc ? 'descending' : 'ascending'}...`);
        setSnackbarOpen(true);
    };

    const handleChangePage = (event, newPage) => {
        setPage(newPage);
        setSnackbarMessage(`Loading page ${newPage}...`);
        setSnackbarOpen(true);
    };

    const handleChangeRowsPerPage = (event) => {
        setRowsPerPage(parseInt(event.target.value, 10));
        setPage(0);
        setSnackbarMessage(`Showing ${parseInt(event.target.value, 10)} results...`);
        setSnackbarOpen(true);
    };

    // requestSearch = (searched) => {
    //     setCopyRows(rows.filter((row) => row.name.toLowerCase().includes(searched.toLowerCase())));
    // }

    useEffect(() => {
        fetch(`http://${HOST}:${PORT}/users`)
            .then((res) => res.text())
            // .then((res) => {return JSON.parse(res.replace(/"id":(\d+)/g, '"id": "$1"').replace(/"id":(\d+),/g, '"id": "$1",'))}) // fix for Javascript's max integer size : bug: does not work for arrays
            .then((res) => {return JSONBig.parse(res);}) // sidorares' fix for bigint parsing - thank you so much
            .then(
                (result) => {
                    setIsLoaded(true);
                    for (let i = 0; i < result['users'].length; i++) {
                        result['users'][i]['id'] = result['users'][i]['id'].toString();
                        result['users'][i]['name'] = result['users'][i]['name'] + "#" + result['users'][i]['discriminator'];
                        result['users'][i]['mutual_guilds_data'] = result['users'][i]['mutual_guilds']['guilds'];
                        result['users'][i]['mutual_guilds'] = result['users'][i]['mutual_guilds']['guilds'].length;
                        result['users'][i]['connected_accounts'] = result['users'][i]['connected_accounts'].length;
                        result['users'][i]['public_flags'] = result['users'][i]['public_flags'].length;
                        result['users'][i]['activities'] = result['users'][i]['activities'].length;
                        result['users'][i]['status'] = result['users'][i]['status'].length;
                        result['users'][i]['premium_since'] = new Date(result['users'][i]['premium_since'] * 1000).toLocaleDateString("en-US", {
                            month: "2-digit",
                            day: "2-digit",
                            year: "numeric",
                            hour: "2-digit",
                            minute: "2-digit"
                        });
                        result['users'][i]['last_scanned'] = new Date(result['users'][i]['last_scanned'] * 1000).toLocaleDateString("en-US", {
                            month: "2-digit",
                            day: "2-digit",
                            year: "numeric",
                            hour: "2-digit",
                            minute: "2-digit"
                        });
                        result['users'][i]['first_seen'] = new Date(result['users'][i]['first_seen'] * 1000).toLocaleDateString("en-US", {
                            month: "2-digit",
                            day: "2-digit",
                            year: "numeric",
                            hour: "2-digit",
                            minute: "2-digit"
                        });
                    }
                    setRows(result['users']);
                    setRetry(false);
                },
                (error) => {
                    setIsLoaded(true);
                    setError(error);
                    setRetry(true);
                    console.log(error);
                }
            )
    }, [page, rowsPerPage, retry]);

    const emptyRows = page > 0 ? Math.max(0, (1 + page) * rowsPerPage - rows.length) : 0;
    if (error) {
        return (
            <Box sx={{ width: '80%', margin: 'auto' }}>
                <Paper sx={{ width: '100%', mb: 2, padding: '36px' }}>
                    <Typography variant="h5" component="h3">
                        Error: {error.message}
                    </Typography>
                    <Button variant="contained" color="primary" onClick={() => setRetry(true)} sx={{ margin: '12px' }}>Retry</Button>
                </Paper>
            </Box>
        )
    } else if (!isLoaded) {
        return (
            <Box sx={{ width: '80%', margin: 'auto' }}>
                <Paper sx={{ width: '100%', mb: 2, padding: '36px' }}>
                    <Typography variant="h5" component="h3">
                        Loading...
                    </Typography>
                </Paper>
            </Box>
        )
    }

    return (
        <Box sx={{ width: '80%', margin: 'auto' }}>
            <Paper sx={{ width: '100%', mb: 2 }}>
                <EnhancedTableToolbar />
                <TableContainer>
                    <Table
                        sx={{ minWidth: 750 }}
                        aria-labelledby="tableTitle"
                        size="medium"
                    >
                        <EnhancedTableHead
                            order={order}
                            orderBy={orderBy}
                            onRequestSort={handlerRequestSort}
                            rowCount={rows.length}
                        />
                        <TableBody>
                            {(copyRows.length > 0 ? copyRows : rows).slice().sort(getComparator(order, orderBy))
                                .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
                                .map((row, index) => {
                                    const labelId = `enhanced-table-row-${index}`;
                                    return (
                                        <TableRow
                                            hover
                                            tabIndex={-1}
                                            key={row.id}
                                        >
                                            <TableCell
                                                component={Link}
                                                to={`/user?id=${row.id}`}
                                                id={labelId}
                                                scope="row"
                                                padding="none"
                                                align='right'
                                                sx={{ paddingLeft: '16px', minWidth: '70px' }}
                                            >
                                                {row.id}
                                            </TableCell>
                                            <Tooltip title={row.name} placement="top" arrow>
                                                <TableCell align='left' sx={{
                                                    minWidth: '70px',
                                                    overflow: 'hidden',
                                                    whiteSpace: 'nowrap',
                                                    textOverflow: 'ellipsis',
                                                    maxWidth: '200px',
                                                }}
                                                    component={Link}
                                                    to={`/user?id=${row.id}`}
                                                >
                                                    {row.name}
                                                </TableCell>
                                            </Tooltip>

                                            <Tooltip title={row.bio !== "None" ? row.bio : ""} placement="top" arrow>
                                                <TableCell align='left' sx={{
                                                    minWidth: '70px',
                                                    overflow: 'hidden',
                                                    whiteSpace: 'nowrap',
                                                    textOverflow: 'ellipsis',
                                                    maxWidth: '200px',
                                                }}>
                                                    {row.bio !== "None" ? row.bio : ""}
                                                </TableCell>
                                            </Tooltip>

                                            <TableCell align="center">
                                                <Tooltip title={<><img src={getSmallerIcon(row.avatar_url)} alt="Profile" /></>} placement="left" arrow>
                                                    <Button variant="text" onClick={() => window.open(row.avatar_url, '_blank', 'noopener, noreferrer')}>Link</Button>
                                                </Tooltip>
                                            </TableCell>

                                            <Tooltip title={"Seen in " + row.mutual_guilds + " guild(s). Click for more details"} placement="right" arrow>
                                                <TableCell align="left">
                                                    <Button variant="text" onClick={() => handleGuildsOpen(row.mutual_guilds_data, row.name)}>{row.mutual_guilds}</Button>
                                                </TableCell>
                                            </Tooltip>

                                            <TableCell align="left">
                                                {row.premium === "True" ? "Yes" : "No"}
                                            </TableCell>

                                            <Tooltip title={row.connected_accounts}>
                                                <TableCell align="left">
                                                    {row.connected_accounts}
                                                </TableCell>
                                            </Tooltip>

                                            <Tooltip title={row.public_flags} placement="top" arrow>
                                                <TableCell align="left">
                                                    {row.public_flags}
                                                </TableCell>
                                            </Tooltip>

                                            <TableCell align="center">
                                                {row.created_at}
                                            </TableCell>

                                            <Tooltip title={row.activities} placement="top" arrow>
                                                <TableCell align="left">
                                                    {row.activities}
                                                </TableCell>
                                            </Tooltip>

                                            <Tooltip title={row.status} placement="top" arrow>
                                                <TableCell align="left">
                                                    {row.status}
                                                </TableCell>
                                            </Tooltip>

                                            <TableCell align="center">
                                                {row.premium_since}
                                            </TableCell>

                                            <TableCell align="center">
                                                {row.last_scanned}
                                            </TableCell>

                                            <TableCell align="center">
                                                {row.first_seen}
                                            </TableCell>
                                        </TableRow>
                                    );
                                })}
                            {emptyRows > 0 && (<TableRow style={{ height: 53 * emptyRows }}></TableRow>)}
                        </TableBody>
                    </Table>
                </TableContainer>
                <TablePagination 
                    rowsPerPageOptions={[10, 25, 50, 100]}
                    component="div"
                    count={rows.length}
                    rowsPerPage={rowsPerPage}
                    page={page}
                    onPageChange={handleChangePage}
                    onRowsPerPageChange={handleChangeRowsPerPage}
                />
                <Modal
                    open={guildsModalOpen}
                    onClose={handleGuildsClose}
                    aria-labelledby="guilds-modal-title"
                    aria-describedby="guilds-modal-description"
                >
                    <Box
                        sx={{
                            position: 'fixed',
                            top: '50%',
                            left: '50%',
                            transform: 'translate(-50%, -50%)',
                            width: '400',
                            bgcolor: 'background.paper',
                            border: '1px solid #000',
                            boxShadow: 24,
                            p: 4,
                            borderradious: '4px',
                        }}
                        >
                            <Typography variant="h4" component="h4">
                                <b>{currentGuildsModal}'s guilds:</b>
                            </Typography>
                            <List>
                                {guildsModalGuilds.map((guild, index) => (
                                    <ListItem key={guild.name} disablePadding>
                                        <ListItemText primary={guild.name} secondary={guild.id} />
                                        <Button component={Link} to={`/guild?id=${guild.id}`}>{guild.name}</Button>
                                    </ListItem>
                                ))}
                            </List>
                        </Box>
                </Modal>
                <Snackbar 
                    open={snackbarOpen}
                    autoHideDuration={6000}
                    onClose={handleSnackbarClose}
                    message={snackbarMessage}
                    action={snackbarAction}
                />
            </Paper>
        </Box>
    )
}
