import { Box } from "@mui/material";

export default function StatusIndicator({status, style}) {
    //
    return (
        <Box
            component="div"
            sx={{
                position: 'absolute',
                top: '100%',
                left: '100%',
                transform: 'translate(-40px, -40px)',
                borderRadius: '50%',
                background: '#303030',
                overflow: 'hidden',
                display: 'grid',
                placeItems: 'center',
                float: 'left',
                border: '5px solid #000000',
                ...style
            }}
            className={`user_indicator ${status}`}
        >
            <Box className="user_status" sx={{
                width: '22px',
                height: '22px',
                borderRadius: '50%',
            }}></Box>
        </Box>
    )
}